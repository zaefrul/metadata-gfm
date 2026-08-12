# Return Item Module - Authorization Issue

**Date**: 10 November 2025  
**Status**: 🔴 BLOCKER - Backend Configuration Issue  

## Problem Description

The mobile app is unable to call the `/api/m_inventory.php` endpoints due to authorization failure.

### Error Message
```
flutter: https://gems.metadatasystem.my/api/m_inventory.php/return_eligible_items/1
flutter: Parameter Authorization empty
```

### Evidence
1. **Other endpoints work fine**: `/user_signature/` endpoint successfully authenticates with the same token
2. **Headers are being sent**: The Provider class `init()` method is setting the token correctly
3. **Error is backend-side**: The error message "Parameter Authorization empty" comes from the PHP backend

### Root Cause Analysis

The `/api/m_inventory.php` PHP script is not receiving or not reading the `Authorization` header correctly.

**Possible causes**:
1. **PHP configuration**: The server might not be passing `Authorization` header to PHP
2. **Apache/Nginx config**: Missing `SetEnvIf` or `FastCGI` configuration for Authorization header
3. **PHP code**: The script might be checking `$_POST['Authorization']` instead of `$_SERVER['HTTP_AUTHORIZATION']`
4. **htaccess**: Missing rewrite rules for Authorization header

### Working vs Non-Working Comparison

**Working** (`/user_signature/` endpoint):
```dart
flutter: GET request to: https://gems.metadatasystem.my/user_signature/1
flutter: {"success":true,"result":{...},"error":"","errmsg":""}
flutter: 200
```

**Not Working** (`/api/m_inventory.php` endpoint):
```dart
flutter: https://gems.metadatasystem.my/api/m_inventory.php/return_eligible_items/1
flutter: Parameter Authorization empty
```

Both use the same Provider class, same headers, same token format.

---

## Backend Team Action Items

### 1. Check PHP Script Authorization Handling

**File**: `api/m_inventory.php`

**Current (probably wrong)**:
```php
<?php
$auth = $_POST['Authorization'] ?? '';  // ❌ Won't work for GET requests
// or
$auth = $_GET['Authorization'] ?? '';   // ❌ Headers aren't in $_GET
```

**Correct approach**:
```php
<?php
// Check multiple possible locations
$headers = getallheaders();
$auth = '';

if (isset($headers['Authorization'])) {
    $auth = $headers['Authorization'];
} elseif (isset($_SERVER['HTTP_AUTHORIZATION'])) {
    $auth = $_SERVER['HTTP_AUTHORIZATION'];
} elseif (isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
    $auth = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
}

if (empty($auth)) {
    echo json_encode([
        'success' => false,
        'result' => null,
        'error' => 'Parameter Authorization empty',
        'errmsg' => 'Authorization header missing'
    ]);
    exit;
}

// Continue with token validation...
```

### 2. Check Apache/Nginx Configuration

**Apache (.htaccess)**:
```apache
# Ensure Authorization header is passed to PHP
SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
```

**Nginx (nginx.conf)**:
```nginx
location ~ \.php$ {
    fastcgi_pass unix:/var/run/php/php-fpm.sock;
    fastcgi_param HTTP_AUTHORIZATION $http_authorization;
    # ... other fastcgi_params
}
```

### 3. Test Authorization Header Receipt

Add temporary debug logging to `api/m_inventory.php`:

```php
<?php
// Temporary debug - REMOVE AFTER TESTING
file_put_contents('/tmp/inventory_headers.log', 
    date('Y-m-d H:i:s') . "\n" . 
    "Headers: " . print_r(getallheaders(), true) . "\n" .
    "HTTP_AUTH: " . ($_SERVER['HTTP_AUTHORIZATION'] ?? 'NOT SET') . "\n" .
    "REDIRECT_AUTH: " . ($_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? 'NOT SET') . "\n\n",
    FILE_APPEND
);
```

Then check `/tmp/inventory_headers.log` after a mobile app request.

### 4. Compare with Working Endpoint

Check how `/api/user_signature.php` (or wherever `/user_signature/` is handled) reads the Authorization header and replicate that pattern in `/api/m_inventory.php`.

---

## Mobile Team Workaround (Temporary)

### Option 1: Use POST Instead of GET

Some PHP configurations handle POST headers better:

```dart
Provider provider = Provider(fetchURL: "/api/m_inventory.php");
var response = await provider.post(
  url: "/api/m_inventory.php/return_eligible_items/$userId",
  body: {},  // Empty body
);
```

**Backend change needed**: Update endpoints to accept POST

### Option 2: Pass Token as Query Parameter (NOT RECOMMENDED)

```dart
Provider provider = Provider(
  fetchURL: "/api/m_inventory.php/return_eligible_items/$userId?token=${user.token}"
);
```

**Security risk**: Token visible in logs, URL history

### Option 3: Use Custom Header Name

If standard `Authorization` header is being stripped, try custom header:

```dart
var response = await http.get(uri, headers: {
  "X-Auth-Token": token,  // Custom header name
  "deviceid": deviceID,
});
```

**Backend change needed**: Read from `X-Auth-Token` instead

---

## Testing Checklist

Once backend fix is deployed:

- [ ] Test GET `/return_eligible_items/:userId`
- [ ] Test POST `/request_return`
- [ ] Test GET `/storekeeper_pending_returns`
- [ ] Test GET `/return_detail/:returnId`
- [ ] Test PUT `/confirm_return/:returnId`
- [ ] Verify all requests include valid Authorization header
- [ ] Verify all requests return proper error messages for invalid tokens
- [ ] Test with expired token
- [ ] Test with invalid device ID

---

## Timeline

- **Issue Discovered**: 10 November 2025, during initial testing
- **Mobile Implementation**: Complete, blocked on backend
- **Backend Fix Required**: ASAP (blocks entire feature)
- **Estimated Fix Time**: 30-60 minutes (backend team)
- **Testing After Fix**: 15-30 minutes

---

## Contact

- **Mobile Team**: Confirmed headers are being sent correctly
- **Backend Team**: Need to investigate `/api/m_inventory.php` authorization handling
- **DevOps Team**: May need to check server/PHP configuration

---

## Resolution

**Status**: 🔴 Waiting for backend team

**Next Steps**:
1. Backend team investigates authorization header handling in `/api/m_inventory.php`
2. Backend team compares with working endpoint (e.g., `/user_signature/`)
3. Backend team implements fix (likely 5-10 lines of code)
4. Backend team deploys fix to production
5. Mobile team retests and verifies all endpoints work
6. Mark issue as resolved

**This is a backend configuration/implementation issue, not a mobile app issue.**
