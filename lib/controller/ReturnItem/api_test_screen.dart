import 'package:flutter/material.dart';
import 'package:GEMS/model/user.dart';
import 'package:GEMS/utils/network.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

/// API Test Screen - Tests Return Items API with current session
/// This helps debug the authorization issue
class ApiTestScreen extends StatefulWidget {
  @override
  _ApiTestScreenState createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _testResults = '';
  bool _testing = false;
  User? _currentUser;
  String? _token;
  String? _deviceId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      var pref = await User.getPrefUser;
      _currentUser = User.fromMap(pref);
      _token = _currentUser?.token ?? '';
      _deviceId = await getDeviceDetails();
      
      setState(() {
        _testResults = 'User loaded. Ready to test.\n\n' +
            'User ID: ${_currentUser?.userID}\n' +
            'Token: ${_token?.substring(0, 30)}...\n' +
            'Device ID: $_deviceId';
      });
    } catch (e) {
      setState(() {
        _testResults = 'Error loading user: $e';
      });
    }
  }

  Future<void> _runTests() async {
    if (_currentUser == null || _token == null) {
      setState(() {
        _testResults = 'Error: No user session found. Please login first.';
      });
      return;
    }

    setState(() {
      _testing = true;
      _testResults = 'Running API tests...\n\n';
    });

    StringBuffer results = StringBuffer();
    results.writeln('=== API AUTHORIZATION TEST ===');
    results.writeln('Time: ${DateTime.now()}');
    results.writeln('User ID: ${_currentUser!.userID}');
    results.writeln('Device ID: $_deviceId');
    results.writeln('Token: ${_token!.substring(0, 30)}...');
    results.writeln('\n' + '='*50 + '\n');

    // Test 1: Return eligible items (NEW endpoint - FAILING)
    results.writeln('TEST 1: Return Eligible Items (NEW endpoint)');
    await _testEndpoint(
      results,
      url: 'https://gems.metadatasystem.my/api/m_inventory.php?action=return_eligible_items&id=${_currentUser!.userID}',
      description: 'Return Eligible Items',
    );

    results.writeln('\n' + '='*50 + '\n');

    // Test 2: User signature (WORKING endpoint)
    results.writeln('TEST 2: User Signature (WORKING endpoint)');
    await _testEndpoint(
      results,
      url: 'https://gems.metadatasystem.my/user_signature/${_currentUser!.userID}',
      description: 'User Signature',
    );

    results.writeln('\n' + '='*50 + '\n');
    results.writeln('ANALYSIS:');
    
    setState(() {
      _testResults = results.toString();
      _testing = false;
    });
  }

  Future<void> _testEndpoint(StringBuffer results, {
    required String url,
    required String description,
  }) async {
    results.writeln('URL: $url');
    results.writeln('');
    results.writeln('Request Headers:');
    results.writeln('  Authorization: Bearer ${_token!.substring(7, 30)}...');
    results.writeln('  deviceid: $_deviceId');
    results.writeln('  Content-Type: application/json');
    results.writeln('');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $_token',
          "deviceid": _deviceId ?? '',
          HttpHeaders.contentTypeHeader: "application/json",
        },
      ).timeout(Duration(seconds: 10));

      results.writeln('Response Status: ${response.statusCode}');
      results.writeln('');
      results.writeln('Response Body:');
      
      try {
        var jsonBody = json.decode(response.body);
        var prettyJson = JsonEncoder.withIndent('  ').convert(jsonBody);
        results.writeln(prettyJson);
        
        // Check for errors
        if (jsonBody is Map) {
          if (jsonBody['success'] == false) {
            results.writeln('');
            results.writeln('⚠️ API returned success=false');
            if (jsonBody['errmsg'] != null && jsonBody['errmsg'] != '') {
              results.writeln('Error message: ${jsonBody['errmsg']}');
              
              if (jsonBody['errmsg'].toString().contains('Authorization empty')) {
                results.writeln('');
                results.writeln('❌ CONFIRMED: Authorization header NOT received by backend');
                results.writeln('   This is a BACKEND configuration issue.');
              }
            }
          } else if (jsonBody['success'] == true) {
            results.writeln('');
            results.writeln('✅ API call successful!');
          }
        }
      } catch (e) {
        results.writeln(response.body);
      }
    } catch (e) {
      results.writeln('❌ ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Authorization Test'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Return Items API Test',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'This will test the API call with your current session token to see the exact error returned by the backend.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _testing ? null : _runTests,
                  icon: Icon(_testing ? Icons.hourglass_empty : Icons.play_arrow),
                  label: Text(_testing ? 'Testing...' : 'Run API Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: SelectableText(
                _testResults,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
