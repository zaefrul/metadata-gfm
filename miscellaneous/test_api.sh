#!/bin/bash

# Test script for Return Items API authorization
# This will help debug the authorization issue

echo "=== Return Items API Authorization Test ==="
echo ""

# Check if token and user ID are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./test_api.sh <token> <user_id> [device_id]"
    echo ""
    echo "Example:"
    echo "  ./test_api.sh 'Bearer eyJ0eXAiOiJKV1QiLCJhbG...' 1 'iPhone16,2'"
    echo ""
    echo "You can get the token from the app logs or user preferences"
    exit 1
fi

TOKEN="$1"
USER_ID="$2"
DEVICE_ID="${3:-test-device-123}"

echo "Testing with:"
echo "  User ID: $USER_ID"
echo "  Device ID: $DEVICE_ID"
echo "  Token: ${TOKEN:0:30}..." # Show only first 30 chars
echo ""
echo "="*70
echo ""

# Test 1: Return eligible items (NEW endpoint - FAILING)
echo "TEST 1: Return Eligible Items (NEW endpoint)"
echo "URL: https://gems.metadatasystem.my/api/m_inventory.php/return_eligible_items/$USER_ID"
echo ""
echo "Request Headers:"
echo "  Authorization: $TOKEN"
echo "  deviceid: $DEVICE_ID"
echo ""

RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  -H "Authorization: $TOKEN" \
  -H "deviceid: $DEVICE_ID" \
  -H "Content-Type: application/json" \
  "https://gems.metadatasystem.my/api/m_inventory.php/return_eligible_items/$USER_ID")

HTTP_BODY=$(echo "$RESPONSE" | sed -e 's/HTTP_STATUS\:.*//g')
HTTP_STATUS=$(echo "$RESPONSE" | tr -d '\n' | sed -e 's/.*HTTP_STATUS://')

echo "Response Status: $HTTP_STATUS"
echo "Response Body:"
echo "$HTTP_BODY" | jq '.' 2>/dev/null || echo "$HTTP_BODY"
echo ""
echo "="*70
echo ""

# Test 2: User signature (WORKING endpoint for comparison)
echo "TEST 2: User Signature (WORKING endpoint for comparison)"
echo "URL: https://gems.metadatasystem.my/user_signature/$USER_ID"
echo ""
echo "Request Headers:"
echo "  Authorization: $TOKEN"
echo "  deviceid: $DEVICE_ID"
echo ""

RESPONSE2=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  -H "Authorization: $TOKEN" \
  -H "deviceid: $DEVICE_ID" \
  -H "Content-Type: application/json" \
  "https://gems.metadatasystem.my/user_signature/$USER_ID")

HTTP_BODY2=$(echo "$RESPONSE2" | sed -e 's/HTTP_STATUS\:.*//g')
HTTP_STATUS2=$(echo "$RESPONSE2" | tr -d '\n' | sed -e 's/.*HTTP_STATUS://')

echo "Response Status: $HTTP_STATUS2"
echo "Response Body:"
echo "$HTTP_BODY2" | jq '.' 2>/dev/null || echo "$HTTP_BODY2"
echo ""
echo "="*70
echo ""

# Analysis
echo "ANALYSIS:"
if echo "$HTTP_BODY" | grep -q "Authorization empty"; then
    echo "❌ CONFIRMED: Authorization header not being received by /api/m_inventory.php"
    echo "   The endpoint returns 'Parameter Authorization empty'"
    echo ""
    echo "   This is a BACKEND ISSUE. The PHP script is not reading the Authorization header."
    echo ""
    echo "   Backend team should check:"
    echo "   1. Use getallheaders() to read Authorization header"
    echo "   2. Check \$_SERVER['HTTP_AUTHORIZATION']"
    echo "   3. Check \$_SERVER['REDIRECT_HTTP_AUTHORIZATION']"
    echo "   4. Verify Apache/Nginx is passing Authorization header"
elif [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Authorization working! The issue may have been fixed."
else
    echo "⚠️  Unexpected response. Status: $HTTP_STATUS"
fi

if [ "$HTTP_STATUS2" = "200" ]; then
    echo "✅ Other endpoints authenticate successfully (proves mobile app is correct)"
else
    echo "❌ Both endpoints failing - may be a token issue"
fi
