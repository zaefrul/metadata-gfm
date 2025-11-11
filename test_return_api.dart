import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

/// Test script to debug the Return Items API authorization issue
/// Run with: dart run test_return_api.dart
void main() async {
  print("=== Return Items API Test ===\n");
  
  // Get device ID (same as Provider class does)
  String deviceId = await getDeviceId();
  print("Device ID: $deviceId");
  
  // Test credentials - replace with actual values
  print("\nPlease provide test credentials:");
  print("Enter user token (Bearer included): ");
  stdout.write("> ");
  String? token = stdin.readLineSync();
  
  if (token == null || token.isEmpty) {
    print("ERROR: Token is required");
    return;
  }
  
  print("\nEnter user ID (e.g., 1): ");
  stdout.write("> ");
  String? userId = stdin.readLineSync();
  
  if (userId == null || userId.isEmpty) {
    print("ERROR: User ID is required");
    return;
  }
  
  // Test endpoints
  await testEndpoint(
    url: "https://gems.metadatasystem.my/api/m_inventory.php/return_eligible_items/$userId",
    token: token,
    deviceId: deviceId,
    description: "Return Eligible Items (NEW endpoint)",
  );
  
  print("\n" + "="*60 + "\n");
  
  // Compare with working endpoint
  await testEndpoint(
    url: "https://gems.metadatasystem.my/user_signature/$userId",
    token: token,
    deviceId: deviceId,
    description: "User Signature (WORKING endpoint for comparison)",
  );
}

Future<String> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor ?? '';
  }
  return '';
}

Future<void> testEndpoint({
  required String url,
  required String token,
  required String deviceId,
  required String description,
}) async {
  print("Testing: $description");
  print("URL: $url");
  print("\nRequest Headers:");
  print("  Authorization: $token");
  print("  deviceid: $deviceId");
  print("  Content-Type: application/json");
  
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        HttpHeaders.authorizationHeader: token,
        "deviceid": deviceId,
        HttpHeaders.contentTypeHeader: "application/json",
      },
    ).timeout(Duration(seconds: 10));
    
    print("\nResponse Status: ${response.statusCode}");
    print("Response Headers:");
    response.headers.forEach((key, value) {
      print("  $key: $value");
    });
    
    print("\nResponse Body:");
    try {
      // Try to pretty print JSON
      var jsonBody = json.decode(response.body);
      print(JsonEncoder.withIndent('  ').convert(jsonBody));
      
      // Check for authorization errors
      if (jsonBody is Map) {
        if (jsonBody['success'] == false) {
          print("\n⚠️  API returned success=false");
          if (jsonBody['errmsg'] != null) {
            print("Error message: ${jsonBody['errmsg']}");
          }
          if (jsonBody['error'] != null) {
            print("Error: ${jsonBody['error']}");
          }
        } else if (jsonBody['success'] == true) {
          print("\n✅ API call successful!");
        }
      }
    } catch (e) {
      // Not JSON or malformed
      print(response.body);
    }
    
  } catch (e) {
    print("\n❌ ERROR: $e");
  }
}
