# Backend Fix Required for PPM Batch Sync

**Date**: 12 November 2025  
**Issue**: Batch sync failing with "Parameter action invalid"  
**Status**: 🔴 Backend code change required

---

## Problem Summary

The mobile app is successfully sending JSON POST requests to `/api/m_ppm.php`, but the backend is returning:
```
❌ Batch sync failed: Parameter action invalid
```

**Evidence from logs**:
```
flutter: 📤 Sending JSON batch request to: https://gems.metadatasystem.my/api/m_ppm.php
flutter:    Payload size: 332 bytes
flutter: 📥 Response status: 200
flutter: ❌ Batch sync failed: Parameter action invalid
```

---

## Root Cause

PHP's `$_POST` superglobal is **NOT automatically populated** when `Content-Type: application/json`. 

The backend code is likely checking `$_POST['action']`, which is **empty** for JSON requests:

```php
// ❌ THIS DOESN'T WORK FOR JSON REQUESTS
$action = $_POST['action'];  // Returns NULL when Content-Type is application/json
if (!$action || $action == '') {
    echo json_encode(['error' => 'Parameter action invalid']);
    exit;
}
```

### Why $_POST is empty:
- `$_POST` is only populated for `Content-Type: application/x-www-form-urlencoded` or `multipart/form-data`
- JSON POST data requires reading from `php://input` stream
- This is standard PHP behavior, not a bug

---

## Required Backend Fix

### File to Modify
```
Backend/gems2/api/m_ppm.php
```

### Current Code (Problematic)
```php
<?php
// Existing code that checks $_POST
$action = $_POST['action'] ?? '';

if ($action == 'batch_sync_offline_actions') {
    // This block NEVER executes for JSON requests
    // ...
}
```

### Fixed Code (Solution)
```php
<?php
// Add this at the top of the file, before checking $action

// Detect Content-Type and read accordingly
$contentType = $_SERVER['CONTENT_TYPE'] ?? '';

if (strpos($contentType, 'application/json') !== false) {
    // Read JSON POST data from input stream
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        echo json_encode(['error' => 'Invalid JSON']);
        exit;
    }
    
    // Populate variables from JSON
    $action = $data['action'] ?? '';
    $metadata = $data['metadata'] ?? [];
    $actions = $data['actions'] ?? [];
} else {
    // Fall back to form-encoded data (existing behavior)
    $action = $_POST['action'] ?? '';
    // ... existing POST handling
}

// Now $action will work for both JSON and form-encoded requests
if ($action == 'batch_sync_offline_actions') {
    // Process batch sync
    $ppmTaskId = $metadata['ppmTaskId'];
    $deviceId = $metadata['deviceId'];
    $syncTimestamp = $metadata['syncTimestamp'];
    
    // Process each action
    foreach ($actions as $actionItem) {
        $actionId = $actionItem['actionId'];
        $actionType = $actionItem['actionType'];
        $timestamp = $actionItem['timestamp'];
        $payload = $actionItem['payload'];
        
        // Process based on actionType...
    }
    
    echo json_encode(['success' => true, ...]);
    exit;
}
```

---

## Request Format (for Backend Reference)

### Headers
```
Content-Type: application/json
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc...
deviceid: 8C6737A8-073E-4A6A-AE50-E55E52968E57
```

### JSON Payload Structure
```json
{
  "action": "batch_sync_offline_actions",
  "metadata": {
    "ppmTaskId": "2123029",
    "deviceId": "8C6737A8-073E-4A6A-AE50-E55E52968E57",
    "syncTimestamp": "2025-11-12 09:30:45"
  },
  "actions": [
    {
      "actionId": "550e8400-e29b-41d4-a716-446655440000",
      "actionType": "save_qualitative_tasks",
      "timestamp": "2025-11-12 08:15:30",
      "payload": {
        "tasks": [
          {
            "ppmTaskQId": "7753796",
            "ppmTaskQResult": "1",
            "ppmTaskQRemark": ""
          }
        ]
      }
    }
  ]
}
```

---

## Testing the Fix

### Before Fix (Current Behavior)
```bash
curl -X POST "https://gems.metadatasystem.my/api/m_ppm.php" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "action": "batch_sync_offline_actions",
    "metadata": {"ppmTaskId": "123"},
    "actions": []
  }'

# Returns: {"error": "Parameter action invalid"}
```

### After Fix (Expected Behavior)
```bash
# Same curl command should return:
{
  "success": true,
  "results": [...],
  "summary": {...}
}
```

### From Mobile App
Once backend fix is deployed, the mobile app will automatically work without any code changes.

---

## Impact

- **Mobile app code**: ✅ Already correct (no changes needed)
- **Backend code**: ❌ Requires fix in `m_ppm.php`
- **API endpoint**: `/api/m_ppm.php` (not `/gems2/api/m_ppm.php` as per docs)
- **Urgency**: HIGH - Feature is deployed but non-functional

---

## Alternative Solutions (Not Recommended)

### Option B: Change mobile to use form-encoded (Don't do this)
```dart
// ❌ NOT RECOMMENDED - Requires reverting to Provider.post() which can't handle nested data
final response = await provider.post(
  url: '/api/m_ppm.php',
  body: batchPayload,  // This fails because nested Maps can't be form-encoded
);
```

**Why this won't work**: Form-encoded POST cannot handle nested objects like `actions[]` array with nested `payload` objects.

### Option C: Use query parameter for action (Hacky)
```dart
// ❌ NOT RECOMMENDED - Breaks REST conventions
final url = Uri.parse('https://gems.metadatasystem.my/api/m_ppm.php?action=batch_sync_offline_actions');
```

**Why this won't work**: Still need to read JSON body for `metadata` and `actions`, so same PHP fix is required.

---

## Recommended Fix: Option A (Proper JSON Handling)

✅ **Modify backend to read JSON from `php://input`**

This is the standard, correct solution that:
- Follows REST API best practices
- Allows nested data structures
- Works with modern HTTP clients
- Is future-proof for other JSON APIs

---

## Questions?

Contact mobile team if:
- Need sample PHP code for specific action types
- Unclear about payload structure
- Need help testing after fix is deployed

**Mobile team ready**: The mobile app is already sending correct JSON. Once backend fix is deployed, batch sync will work immediately.
