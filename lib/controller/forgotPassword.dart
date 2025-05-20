import 'dart:convert'; // Not used in this file, but kept from original context if needed elsewhere
import 'dart:io'; // Not used in this file
import 'dart:typed_data'; // Not used in this file

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Mock Implementations for Dependencies ---
// These mocks are to make the example runnable and demonstrate the UI fix.
// Replace them with your actual implementations.

// Mock AppColorsFP with a new, modern palette
class AppColorsFP {
  static const Color primary = Color(0xFF007AFF); // A modern blue
  static const Color primaryVariant = Color(0xFF0056B3);
  static const Color secondary = Color(0xFF34C759); // A vibrant green for success/accent
  static const Color background = Color(0xFFF2F2F7); // Light system gray
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1C1C1E); // Almost black for primary text
  static const Color textSecondary = Color(0xFF8A8A8E); // Medium gray for secondary text
  static const Color textHint = Color(0xFFC7C7CC); // Light gray for hints
  static const Color error = Color(0xFFFF3B30); // Standard error red
  static const Color white = Colors.white;

  // Kept for compatibility if old colorTheme names are deeply integrated,
  // but ideally, these would be phased out.
  static const Color colorTheme2 = primary; // Map to new primary
  static const Color colorTheme3 = textPrimary; // Map to new text primary
}

// Mock for navigatorKey (used by the alert dialog)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Mock ToastContext and ToastFP
class ToastContextFP {
  void init(BuildContext context) {
    print("ToastContext initialized");
  }
}

class ToastFP {
  static void show(String msg, {Color? backgroundColor, int? duration, int? gravity}) {
    print("ToastFP: $msg (background: $backgroundColor)");
    // In a real app, this would show a toast message.
    // For this example, we just print to console.
    // You could use ScaffoldMessenger for a more modern approach than the 'toast' package.
    if (navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: backgroundColor ?? AppColorsFP.textPrimary.withOpacity(0.8),
          duration: Duration(seconds: duration ?? 2),
        ),
      );
    }
  }
}

// Mock Provider (from utils/network.dart)
class Provider {
  final String fetchURL;
  BuildContext? context; // Context might be needed for dialogs/navigation in real Provider

  Provider({required this.fetchURL});

  Future<dynamic> post({
    required String url,
    required Map<String, dynamic> body,
    bool includedHeader = true, // Added parameter from original code
  }) async {
    print("Mock Provider: post called for URL: $url with body: $body, headers: $includedHeader");
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    // Simulate a success response, adjust as needed for error testing
    return '{"status": "success", "message": "Password reset link sent successfully. Please check your email."}';
    // Simulate an error response:
    // throw Exception('{"status": "error", "message": "User not found."}');
  }
}

// Mock CustomDialog (from gfm_gems/view/dialog.dart)
// This is a simplified mock. Your actual CustomDialog might be more complex.
class CustomDialog extends StatelessWidget {
  final String description;
  final String buttonText;
  final Widget image;
  final VoidCallback? okayTapped; // Made optional
  final String? rootPage; // Added from original

  const CustomDialog({
    Key? key,
    required this.description,
    required this.buttonText,
    required this.image,
    this.okayTapped,
    this.rootPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: image,
      content: Text(
        description,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 16, color: AppColorsFP.textSecondary),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorsFP.primary,
            foregroundColor: AppColorsFP.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            Navigator.pop(context); // Close dialog
            if (okayTapped != null) {
              okayTapped!();
            }
            if (rootPage != null && rootPage!.isNotEmpty) {
              // Handle navigation if needed, e.g.
              // Navigator.of(context).pushNamedAndRemoveUntil(rootPage!, (route) => false);
              print("Dialog: Navigating to $rootPage");
            }
          },
          child: Text(buttonText, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
// --- Uplifted Forgot Password Screen ---

class Forgot extends StatefulWidget {
  const Forgot({Key? key}) : super(key: key);

  @override
  _ForgotState createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  final String titleTxt = "Forgot Password?";
  final String noticeTxt =
      "Enter your email address below and we'll send you a link to reset your password.";
  bool _loading = false;
  String _email = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize ToastContext if it's not a singleton or needs specific context
    // For this example, using ScaffoldMessenger via navigatorKey.currentContext
    // ToastContext().init(context); // Original placement
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email address.";
    }
    // More robust email validation regex
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return "Please enter a valid email address.";
    }
    return null;
  }

  Future<void> _submitForgotPassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _loading = true);

      var bodyProvider = {
        "action": "forgot_password",
        "email": _email,
      };

      // Assuming Provider is set up for your API base URL
      Provider provider = Provider(fetchURL: "/api/m_login.php"); // Base URL might be configured elsewhere

      try {
        var result = await provider.post(
          url: "/api/m_login.php", // Endpoint specific to this action
          body: bodyProvider,
          includedHeader: false, // As per original call
        );

        // Attempt to parse the result as JSON
        Map<String, dynamic> responseJson;
        if (result is String) {
          responseJson = jsonDecode(result) as Map<String, dynamic>;
        } else if (result is Map) {
          responseJson = result as Map<String, dynamic>;
        } else {
          throw Exception("Unexpected response format from server.");
        }
        
        _showAlert(responseJson['message']?.toString() ?? "Password reset link sent.", success: true);

      } catch (err) {
        print("Error during password reset: $err");
        String errorMessage = "An unexpected error occurred. Please try again.";
        if (err is Exception && err.toString().contains("message")) {
           try {
             final errorJson = jsonDecode(err.toString().replaceFirst("Exception: ", "")) as Map<String,dynamic>;
             errorMessage = errorJson['message']?.toString() ?? errorMessage;
           } catch (_){
             // Use default if parsing fails
           }
        } else if (err is String) {
          errorMessage = err;
        }
        _showAlert(errorMessage, success: false);
      } finally {
        if (mounted) {
          setState(() => _loading = false);
        }
      }
    }
  }

  void _showAlert(String message, {bool success = true}) {
    if (navigatorKey.currentContext == null) {
      print("Error: navigatorKey.currentContext is null. Cannot show dialog.");
      return;
    }
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => CustomDialog(
        // Navigate to home or login on success, or stay on page for error
        rootPage: success ? "/" : null, 
        description: message,
        buttonText: "Okay",
        image: Icon(
          success ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
          color: success ? AppColorsFP.secondary : AppColorsFP.error,
          size: 60,
        ),
        // okayTapped: success ? () => Navigator.of(context).popUntil((route) => route.isFirst) : null,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Initialize ToastContext here if needed, or rely on ScaffoldMessenger
    // ToastContext().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(titleTxt),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header Image/Icon
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Icon(
                    Icons.lock_reset_rounded, // Using a Material Icon
                    size: 100,
                    color: AppColorsFP.primary,
                  ),
                  // Or use your asset:
                  // child: Image.asset("assets/Email.png", height: 100, color: AppColorsFP.primary),
                ),

                // Notice Text
                Text(
                  noticeTxt,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColorsFP.textSecondary,
                    height: 1.5, // Improved line spacing
                  ),
                ),
                const SizedBox(height: 32),

                // Email Input Field
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    labelText: "Email Address",
                    prefixIcon: Icon(Icons.email_outlined, color: AppColorsFP.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: AppColorsFP.textHint),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: AppColorsFP.textHint.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: AppColorsFP.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColorsFP.cardBackground,
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(color: AppColorsFP.textPrimary),
                  validator: _validateEmail,
                  onSaved: (value) => _email = value ?? "",
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorsFP.primary,
                    foregroundColor: AppColorsFP.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 2, // Subtle shadow
                  ),
                  onPressed: _loading ? null : _submitForgotPassword,
                  child: _loading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: AppColorsFP.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          "Send Reset Link",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 24), // For bottom spacing
              ],
            ),
          ),
        ),
      ),
    );
  }
}
