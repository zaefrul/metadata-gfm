# Return Item API URL Fix

**Date:** 10 November 2025  
**Issue:** Incorrect API endpoint format causing authorization errors  
**Resolution:** Changed from REST-style paths to query parameter format

---

## Problem

The mobile app was constructed using REST-style URL paths:
```
❌ /api/m_inventory.php/return_eligible_items/{userId}
❌ /api/m_inventory.php/request_return
❌ /api/m_inventory.php/storekeeper_pending_returns
```

But the backend expects traditional PHP query parameters:
```
✅ /api/m_inventory.php?action=return_eligible_items&id={userId}
✅ /api/m_inventory.php (POST with action=request_return in body)
✅ /api/m_inventory.php?action=storekeeper_pending_returns
```

This mismatch caused the backend to not recognize the endpoints and return "Parameter Authorization empty" errors because the routing didn't match.

---

## Changes Made

### File: `lib/controller/ReturnItem/bloc/bloc_return.dart`

#### 1. Load Collected Items (GET)
```dart
// BEFORE
Provider(fetchURL: "/api/m_inventory.php/return_eligible_items/$userId");

// AFTER
Provider(fetchURL: "/api/m_inventory.php?action=return_eligible_items&id=$userId");
```

#### 2. Submit Return Request (POST)
```dart
// BEFORE
Provider(fetchURL: "/api/m_inventory.php/request_return");
body: {
  "woTaskPartsId": woTaskPartsId,
  "quantityReturned": quantityReturned.toString(),
  ...
}

// AFTER
Provider(fetchURL: "/api/m_inventory.php");
body: {
  "action": "request_return",
  "woTaskPartsId": woTaskPartsId,
  "quantityReturned": quantityReturned.toString(),
  ...
}
```

#### 3. Load Pending Returns (GET)
```dart
// BEFORE
Provider(fetchURL: "/api/m_inventory.php/storekeeper_pending_returns");

// AFTER
Provider(fetchURL: "/api/m_inventory.php?action=storekeeper_pending_returns");
```

#### 4. Get Return Detail (GET)
```dart
// BEFORE
Provider(fetchURL: "/api/m_inventory.php/return_detail/$returnId");

// AFTER
Provider(fetchURL: "/api/m_inventory.php?action=return_detail&id=$returnId");
```

#### 5. Confirm Return (PUT)
```dart
// BEFORE
Provider(fetchURL: "/api/m_inventory.php/confirm_return/$returnId");
await provider.put(body: {});

// AFTER
Provider(fetchURL: "/api/m_inventory.php");
await provider.put(body: {
  "action": "confirm_return",
  "id": returnId,
});
```

#### 6. Get Statistics (GET)
```dart
// BEFORE
String url = "/api/m_inventory.php/return_statistics";
if (userId != null) {
  url += "?userId=$userId";
}

// AFTER
String url = "/api/m_inventory.php?action=return_statistics";
if (userId != null) {
  url += "&userId=$userId";
}
```

#### 7. Removed unused variable
```dart
// REMOVED
final String _baseUrl = "/api/m_inventory.php";
```

### File: `lib/controller/ReturnItem/api_test_screen.dart`

Updated test URL to match:
```dart
// BEFORE
url: 'https://gems.metadatasystem.my/api/m_inventory.php/return_eligible_items/${_currentUser!.userID}'

// AFTER
url: 'https://gems.metadatasystem.my/api/m_inventory.php?action=return_eligible_items&id=${_currentUser!.userID}'
```

---

## Testing

### Before Fix
```bash
GET /api/m_inventory.php/return_eligible_items/1
Response: "Parameter Authorization empty"
```

### After Fix
```bash
GET /api/m_inventory.php?action=return_eligible_items&id=1
Response: Should return success with collected items list
```

---

## Endpoint Summary

All endpoints now follow the correct format:

| Method | Endpoint | Parameters |
|--------|----------|------------|
| GET | `/api/m_inventory.php` | `?action=return_eligible_items&id={userId}` |
| POST | `/api/m_inventory.php` | Body: `action=request_return, woTaskPartsId=..., quantityReturned=..., returnReason=...` |
| GET | `/api/m_inventory.php` | `?action=storekeeper_pending_returns` |
| GET | `/api/m_inventory.php` | `?action=return_detail&id={returnId}` |
| PUT | `/api/m_inventory.php` | Body: `action=confirm_return, id={returnId}` |
| GET | `/api/m_inventory.php` | `?action=return_statistics&userId={userId}` (userId optional) |

---

## Root Cause

The API documentation (`MATERIAL_ITEM_API.md`) was written with REST-style paths which is more modern and cleaner:
```
GET /return_eligible_items/{userId}
POST /request_return
```

But the actual PHP backend implementation uses traditional query parameters:
```
GET /api/m_inventory.php?action=return_eligible_items&id={userId}
POST /api/m_inventory.php with action in body
```

This is consistent with other GEMS API endpoints like `/api/m_wo.php?type=...` and follows the legacy PHP pattern used throughout the backend.

---

## Lessons Learned

1. **Always verify API format** - Check existing endpoints in the codebase for patterns
2. **Test early** - The authorization error was actually a routing mismatch, not an auth issue
3. **Document actual implementation** - API docs should match backend reality
4. **Follow established patterns** - Use grep to find similar API calls in the codebase

---

## Next Steps

1. ✅ URL format corrected in all 6 BLoC methods
2. ✅ Test screen updated
3. 🔄 Test the API calls with the corrected URLs
4. 🔄 Update `MATERIAL_ITEM_API.md` to reflect actual query parameter format
5. 🔄 Verify all 4 screens work correctly
6. 🔄 Run full QA testing per `RETURN_ITEM_TESTING_GUIDE.md`
