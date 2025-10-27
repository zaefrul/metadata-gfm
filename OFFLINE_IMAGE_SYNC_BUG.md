# Offline Image Sync Bug - Investigation & Fix

## Bug Report
**Symptom**: When taking Section D response images (Before/During/After photos) in offline mode, after sync the images disappear. The form shows as if the pictures were never taken, but the section turns green indicating "success".

**Severity**: CRITICAL - Data loss affecting work order completion verification

**Date Discovered**: Current investigation

---

## Root Cause Analysis

### The Problem Flow

1. **Offline Image Capture** ✅
   - User takes photos in Section D while offline
   - `uploadResponseImage()` is called with base64-encoded image data
   - Action is queued in `work_order_pending_actions` table
   - **Works correctly** - images stored locally

2. **Queue Storage** ✅
   - Payload includes: `action='upload_response_image'`, base64Data, uploadType, location
   - Stored successfully in SQLite database
   - **Works correctly** - data persisted

3. **Sync Trigger** ⚠️
   - User goes online and triggers sync
   - `syncPendingActions()` loops through pending actions
   - For each action: decodes JSON → calls `_post(body)` → removes from queue on success
   - **PROBLEM**: On first error, loop breaks without removing failed action

4. **API Upload Failure** ❌
   - `_post()` calls `Provider.post()` which makes HTTP POST to `/api/m_wo.php`
   - API likely returns `{"success": false, "errmsg": "..."}`
   - Possible reasons:
     - Base64 payload too large (>1MB images)
     - API timeout (default 30s may not be enough)
     - Server-side validation error
     - PHP memory limit exceeded
   - `Provider.post()` throws `Future.error(responseValue.errmsg)` (line 341 in utils/network.dart)

5. **Error Handling Bug** ❌
   - `syncPendingActions()` catches error (line 1091 in work_order_detail_repository.dart)
   - Logs with `debugPrint()` - **user never sees this**
   - **Calls `break;` instead of `continue;`** ← THE BUG
   - Failed action remains in queue forever

6. **UI State Confusion** ❌
   - UI's `_watchPendingSync()` sees pending count change
   - Calls `_loadExisting(force: true)` to refresh from server
   - Server has no images (upload failed), so list is empty
   - Section shows **green** because local state thinks work is queued/complete
   - Images disappear from UI

### Code Evidence

**File: `lib/data/repository/work_order_detail_repository.dart`**

Lines 1069-1096 (BEFORE FIX):
```dart
Future<void> syncPendingActions() async {
  final pending = await _database.getPendingActions();
  if (pending.isEmpty) return;

  for (final action in pending) {
    try {
      if (action.action == 'rest') {
        final payload = json.decode(action.payloadJson) as Map<String, dynamic>;
        await _sendRest(payload);
      } else {
        final body = json.decode(action.payloadJson) as Map<String, dynamic>;
        await _post(body);
      }
      if (action.id != null) {
        await _database.removePendingAction(action.id!);
      }
    } on SocketException catch (_) {
      break;  // OK - network unavailable
    } on TimeoutException catch (_) {
      break;  // OK - network unavailable
    } catch (err) {
      debugPrint('Failed to replay action ${action.id}: $err');
      break;  // ← BUG: Should be 'continue;' to try other actions!
    }
  }
}
```

**File: `lib/utils/network.dart`**

Lines 306-345:
```dart
Future<dynamic> post({required String url, dynamic body, bool includedHeader = true}) async {
  // ... HTTP POST to netDomain + url ...
  
  if (response.statusCode == 200) {
    var decode = json.decode(response.body);
    
    ResponseValue responseValue = serializers.deserializeWith(
        ResponseValue.serializer, json.decode(response.body))!;

    if (responseValue.success == true) {
      // ... return success
    } else {
      return Future.error(responseValue.errmsg);  // ← Throws, caught by syncPendingActions
    }
  }
  return Future.error("Please try again.");
}
```

---

## Applied Fixes

### Fix #1: Change Error Handling Strategy ✅ APPLIED

**Changed**: `break;` → `continue;` in error handler + added failure tracking

**File**: `lib/data/repository/work_order_detail_repository.dart`

**What it does**:
- Continues processing other actions even if one fails
- Tracks failed actions for logging
- Only breaks on connectivity errors (SocketException/TimeoutException)
- Provides summary of sync results

**Result**: Failed image uploads no longer block other pending actions from syncing

### Fix #2: Enhanced Diagnostic Logging ✅ APPLIED

**File**: `lib/data/repository/work_order_detail_repository.dart` - `_post()` method

**Added logging for**:
- Image upload size (in KB) before sending
- Action type and workOrderId
- Success/failure status with detailed error messages

**Result**: Developers can now see:
```
Uploading image: action=upload_response_image, woTaskId=WO123, size=2847.32KB
Failed to post action=upload_response_image for woTaskId=WO123: File size exceeds limit
```

---

## Remaining Issues to Fix

### Priority 1: Identify WHY Images Are Failing

**Action Required**: Test with real offline images and check debug logs

**Check for**:
1. **Image size limits**
   - Check if base64 payload exceeds PHP `post_max_size` or `upload_max_filesize`
   - Typical mobile photos: 2-5MB raw → 3-7MB base64
   - Recommendation: Compress images to <500KB before base64 encoding

2. **API timeout**
   - Large base64 strings take time to transmit
   - Check if server timeout (30s) is sufficient
   - Recommendation: Increase timeout or implement chunked upload

3. **Server-side validation**
   - Check API logs for actual error messages
   - Verify API accepts `action=upload_response_image`
   - Check if all required fields are present

4. **PHP memory limit**
   - Base64 decoding requires additional memory
   - Check PHP `memory_limit` setting
   - Recommendation: Set to at least 256MB

### Priority 2: Implement Retry Logic with Exponential Backoff

**Current**: Failed actions stay in queue forever, retried on every sync

**Problem**: If error is permanent (e.g., image too large), sync will fail forever

**Recommended Solution**:

```dart
// Add to work_order_pending_actions table schema
ALTER TABLE work_order_pending_actions ADD COLUMN retry_count INTEGER DEFAULT 0;
ALTER TABLE work_order_pending_actions ADD COLUMN last_retry_at INTEGER;
ALTER TABLE work_order_pending_actions ADD COLUMN error_message TEXT;

// In syncPendingActions():
const maxRetries = 5;
const baseBackoffSeconds = 30;

for (final action in pending) {
  // Skip if max retries exceeded
  if (action.retryCount >= maxRetries) {
    debugPrint('Action ${action.id} exceeded max retries (${action.retryCount})');
    await _database.markActionAsFailed(action.id!, err.toString());
    continue;
  }

  // Skip if backoff period not elapsed
  final backoffSeconds = baseBackoffSeconds * pow(2, action.retryCount);
  if (action.lastRetryAt != null) {
    final elapsed = DateTime.now().difference(action.lastRetryAt!).inSeconds;
    if (elapsed < backoffSeconds) {
      debugPrint('Action ${action.id} in backoff period (${backoffSeconds - elapsed}s remaining)');
      continue;
    }
  }

  try {
    // ... attempt sync ...
    await _database.removePendingAction(action.id!);
  } catch (err) {
    await _database.incrementRetryCount(action.id!, err.toString());
    continue;
  }
}
```

### Priority 3: Add User-Facing Error Feedback

**Current**: Errors only logged to debug console

**Problem**: Users think sync succeeded, don't know images failed

**Recommended Solution**:

```dart
// Return sync results from syncPendingActions()
class SyncResult {
  final int succeeded;
  final int failed;
  final List<String> failedActions;
  final bool hasConnectivityIssue;
}

Future<SyncResult> syncPendingActions() async {
  // ... sync logic ...
  return SyncResult(
    succeeded: successCount,
    failed: failedActions.length,
    failedActions: failedActions,
    hasConnectivityIssue: hasConnectivityError,
  );
}

// In mainBloc.dart:
Future<void> retryPendingSync() async {
  final result = await _repository.syncPendingActions();
  await _refreshPendingCount();
  await _load(forceRefresh: true);
  
  if (result.failed > 0) {
    _feedback.add(MutationFeedback(
      message: 'Synced ${result.succeeded} actions. ${result.failed} failed - check details',
      type: MutationFeedbackType.warning,
    ));
  }
}
```

### Priority 4: Improve Section Status Indicators

**Current**: Section shows green even if images failed to upload

**Problem**: Misleading - user thinks everything is done

**Recommended Solution**:

Add distinct states:
- 🟡 **Yellow**: Queued locally, not yet synced
- 🔵 **Blue**: Syncing in progress
- 🟢 **Green**: Successfully synced to server
- 🔴 **Red**: Failed to sync (manual review needed)

Implementation:
```dart
enum SectionCompletionStatus {
  incomplete,    // User hasn't filled section
  queued,        // Offline changes queued
  syncing,       // Currently uploading
  synced,        // All data on server
  failed,        // Some actions failed
}

// Check pending actions to determine status
Future<SectionCompletionStatus> getSectionStatus(String woTaskId, String sectionName) async {
  final pending = await getPendingActions();
  final sectionPending = pending.where((a) => 
    a.workOrderId == woTaskId && a.action.contains(sectionName)
  ).toList();
  
  if (sectionPending.isEmpty) return SectionCompletionStatus.synced;
  
  final anyFailed = sectionPending.any((a) => a.retryCount >= maxRetries);
  if (anyFailed) return SectionCompletionStatus.failed;
  
  return SectionCompletionStatus.queued;
}
```

### Priority 5: Implement Image Compression

**Current**: Full-resolution images encoded as base64

**Problem**: 5MP camera photo = ~3-5MB base64, may exceed API limits

**Recommended Solution**:

```dart
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<Uint8List> compressImage(Uint8List imageBytes) async {
  final result = await FlutterImageCompress.compressWithList(
    imageBytes,
    minWidth: 1920,  // Max width
    minHeight: 1080, // Max height
    quality: 85,     // JPEG quality (0-100)
    format: CompressFormat.jpeg,
  );
  
  debugPrint('Compressed ${imageBytes.length} bytes → ${result.length} bytes '
    '(${(result.length / imageBytes.length * 100).toStringAsFixed(1)}%)');
  
  return result;
}

// In complaintSectionResponseImage.dart, before upload:
Future<void> _submitAll() async {
  for (final item in _toUpload) {
    final compressed = await compressImage(item.bytes);
    final base64Data = base64Encode(compressed);
    
    await _repository.uploadResponseImage(
      workOrderId: widget.woTaskId,
      base64Data: base64Data,
      sizeBytes: compressed.length,
      // ... other params
    );
  }
}
```

---

## Testing Checklist

### Immediate Verification

- [x] Fix #1 applied: Error handling changed from `break` to `continue`
- [x] Fix #2 applied: Enhanced logging in `_post()` method
- [ ] Test with real offline images (take 5 photos, go offline, queue, sync)
- [ ] Check debug console for new diagnostic logs
- [ ] Verify failed actions are logged but don't block other actions
- [ ] Confirm images appear after successful sync

### Root Cause Verification

- [ ] Check server logs during sync - what error is API returning?
- [ ] Measure actual image sizes being uploaded (from debug logs)
- [ ] Test with different image sizes (100KB, 500KB, 1MB, 3MB, 5MB)
- [ ] Check PHP error logs for memory/timeout issues
- [ ] Verify API endpoint accepts `action=upload_response_image`

### Comprehensive Solution Testing

- [ ] Implement retry logic with backoff
- [ ] Test max retry limit (5 retries)
- [ ] Add user-facing error messages
- [ ] Update section status indicators (colors)
- [ ] Implement image compression
- [ ] Test end-to-end: offline capture → compress → queue → sync → verify on server

---

## Monitoring & Prevention

### Add to Copilot Instructions

Already documented in `.github/copilot-instructions.md` under "Known Issues" section.

### Production Monitoring

Recommendations:
1. **Add analytics event** for failed sync actions
2. **Server-side logging** of all `upload_response_image` requests with outcomes
3. **Alert on queue depth** - if pending_actions > 50, investigate
4. **Weekly report** of retry counts and failed actions

### Code Review Checklist

When reviewing offline-related PRs:
- [ ] All error handlers use `continue` not `break` (unless connectivity issue)
- [ ] User-facing feedback for all mutations
- [ ] Retry logic with max attempts
- [ ] Payload size validation before queuing
- [ ] Clear distinction between "queued" and "synced" in UI

---

## Related Files

### Modified in This Fix
- `lib/data/repository/work_order_detail_repository.dart` - syncPendingActions(), _post()

### Related Components
- `lib/controller/WorkOrder/complaintSectionResponseImage.dart` - Image upload UI
- `lib/controller/WorkOrder/bloc/mainBloc.dart` - Sync orchestration
- `lib/data/local/offline_database.dart` - Pending actions queue
- `lib/utils/network.dart` - HTTP POST implementation

### Documentation
- `.github/copilot-instructions.md` - Offline mode patterns
- `OFFLINE_DEBUG_GUIDE.md` - Debugging techniques
- `ROOT_CAUSE_FOUND.md` - Original offline investigation

---

## Timeline

- **2024-01-XX**: Bug reported by user
- **2024-01-XX**: Investigation started, root cause identified
- **2024-01-XX**: Fix #1 and Fix #2 applied
- **2024-01-XX**: Testing in progress
- **Pending**: Priority 1-5 fixes implementation
- **Target**: Production deployment after comprehensive testing

---

## Contact

For questions about this bug fix:
- Check debug console for new diagnostic logs
- Review test results with different image sizes
- Verify server-side API responses during sync
- Monitor production pending_actions table depth

**Next Steps**: 
1. Test current fixes with real offline images
2. Review debug logs to identify specific API error
3. Implement appropriate fix from Priority 1-5 based on findings
