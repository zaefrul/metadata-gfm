# Quick Testing Guide - Offline Image Sync Fix

## What Was Fixed

✅ **Sync error handling** - Changed from `break` (stops all sync) to `continue` (skips failed action, tries others)
✅ **Diagnostic logging** - Added detailed logs for image uploads (size, action, errors)

## What You Need to Test

### Test 1: Verify Fix Works
1. Enable Flutter debug mode (to see `debugPrint` logs)
2. Create a new work order or open existing
3. **Go offline** (airplane mode or disable WiFi)
4. Navigate to Section D (Images)
5. Take 5 photos: 1 Before, 3 During, 1 After
6. Verify photos appear in UI with "pending" indicator
7. **Go online**
8. Tap sync button
9. **Watch debug console** for new log messages

**Expected Logs**:
```
Uploading image: action=upload_response_image, woTaskId=WO123, size=2847.32KB
Successfully posted action=upload_response_image for woTaskId=WO123
Successfully synced action 123 (upload_response_image)
```

OR if it fails:
```
Uploading image: action=upload_response_image, woTaskId=WO123, size=3521.14KB
Failed to post action=upload_response_image for woTaskId=WO123: File size too large
Failed to replay action 123 (upload_response_image): File size too large
Failed to sync 1 actions: upload_response_image (ID: 123)
```

**Check**:
- [ ] Do images appear on server after sync? (refresh work order)
- [ ] Are failed actions still in pending queue?
- [ ] Do successful actions get removed from queue?

### Test 2: Identify Root Cause

If images still fail, look for these patterns in logs:

#### Pattern 1: Image Too Large
```
Uploading image: action=upload_response_image, woTaskId=WO123, size=5284.72KB
Failed to post action=upload_response_image for woTaskId=WO123: File size exceeds limit
```
**Solution**: Implement image compression (see OFFLINE_IMAGE_SYNC_BUG.md Priority 5)

#### Pattern 2: API Timeout
```
Uploading image: action=upload_response_image, woTaskId=WO123, size=2847.32KB
Failed to post action=upload_response_image for woTaskId=WO123: TimeoutException after 30000ms
```
**Solution**: Increase timeout or implement chunked upload

#### Pattern 3: Server Error
```
Uploading image: action=upload_response_image, woTaskId=WO123, size=1247.32KB
Failed to post action=upload_response_image for woTaskId=WO123: Invalid upload type
```
**Solution**: Check API logs, verify payload format

#### Pattern 4: Network Issue
```
Uploading image: action=upload_response_image, woTaskId=WO123, size=2847.32KB
Sync stopped due to connectivity issues
```
**Solution**: User should retry when network is stable

### Test 3: Mixed Actions

Test that other pending actions still sync even if images fail:

1. Go offline
2. Take 2 photos in Section D
3. Add material in Section E
4. Add remark in Section F
5. Go online and sync
6. **Check**: Even if photos fail, material and remark should sync successfully

**Expected**:
```
Successfully synced action 456 (add_material)
Successfully synced action 457 (add_remark)
Failed to replay action 458 (upload_response_image): File size too large
Failed to sync 1 actions: upload_response_image (ID: 458)
```

---

## Debug Console Access

### Android Studio / IntelliJ
1. Run app in debug mode
2. Open "Run" tab at bottom
3. Watch for lines starting with "I/flutter"

### VS Code
1. Run app with "Start Debugging" (F5)
2. Open "Debug Console" panel
3. Watch for Flutter debug output

### Physical Device via ADB
```bash
# Connect device via USB
adb logcat | grep "flutter"

# Or filter for specific logs
adb logcat | grep "upload_response_image"
```

---

## Database Inspection

Check pending actions directly in SQLite:

```bash
# Pull database from device
adb pull /data/data/my.gfm.gems/databases/gems_offline.db

# Open with sqlite3
sqlite3 gems_offline.db

# Query pending actions
SELECT id, work_order_id, action, created_at 
FROM work_order_pending_actions 
ORDER BY created_at DESC;

# Check specific work order
SELECT * FROM work_order_pending_actions 
WHERE work_order_id = 'YOUR_WO_ID';

# Count pending by action type
SELECT action, COUNT(*) 
FROM work_order_pending_actions 
GROUP BY action;
```

---

## What to Report

If images still fail after this fix, provide:

1. **Debug logs** (copy entire sync sequence)
2. **Image sizes** (from "Uploading image: ... size=XXX.XXKB" logs)
3. **Error messages** (from "Failed to post ..." logs)
4. **Server logs** (if accessible) - check `/api/m_wo.php` responses
5. **Network conditions** (WiFi vs mobile data, signal strength)
6. **Device info** (Android/iOS version, device model)

**Example Report**:
```
ISSUE: Images still failing after fix

LOGS:
Uploading image: action=upload_response_image, woTaskId=WO12345, size=4521.32KB
Failed to post action=upload_response_image for woTaskId=WO12345: Post content length exceeds limit
Failed to sync 3 actions: upload_response_image (ID: 123), upload_response_image (ID: 124), upload_response_image (ID: 125)

IMAGE SIZES:
- Before: 4521.32KB
- During1: 3847.21KB
- During2: 4123.45KB

ERROR: "Post content length exceeds limit"

CONCLUSION: PHP post_max_size is too small. Need to either:
- Increase server limit to 10MB
- OR implement client-side compression to <500KB per image
```

---

## Next Steps Based on Findings

### If images sync successfully:
✅ Bug is fixed! Close ticket.

### If images fail with "size" error:
→ Implement Priority 5: Image Compression
→ See OFFLINE_IMAGE_SYNC_BUG.md for code sample

### If images fail with "timeout" error:
→ Increase HTTP timeout from 30s to 60s
→ Or implement chunked upload

### If images fail with validation error:
→ Check server API logs
→ Verify payload format matches server expectations
→ Test with Postman to isolate client vs server issue

### If other actions also fail:
→ Check network connectivity
→ Verify auth token is valid
→ Check server is responding

---

## Rollback Plan

If this fix causes issues:

```bash
git revert HEAD  # Revert the two commits that applied fixes
```

Original behavior will be restored:
- Sync stops on first error (but at least you'll know WHY from logs)
- Failed actions remain in queue

Then investigate root cause before re-applying fix.
