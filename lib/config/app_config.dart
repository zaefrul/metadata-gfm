// App Configuration for GEMS
// This file handles different app variants while maintaining the same bundle identifier
// to comply with Apple's App Store requirements

class AppConfig {
  // App variant configuration
  static const String _appVariant = String.fromEnvironment('APP_VARIANT', defaultValue: 'classic');
  
  // App variant types
  static const String classic = 'classic';
  static const String client = 'client';
  
  // Current app variant
  static String get currentVariant => _appVariant;
  
  // Check if current variant is classic
  static bool get isClassic => _appVariant == classic;
  
  // Check if current variant is client
  static bool get isClient => _appVariant == client;
  
  // App display configuration based on variant
  static String get appDisplayName {
    switch (_appVariant) {
      case client:
        return 'GEMS 2.0 Client';
      case classic:
      default:
        return 'GEMS 2.0';
    }
  }
  
  // App subtitle for branding
  static String get appSubtitle {
    switch (_appVariant) {
      case client:
        return 'Client Version';
      case classic:
      default:
        return 'Classic';
    }
  }
  
  // Theme customization based on variant
  static Map<String, dynamic> get themeConfig {
    switch (_appVariant) {
      case client:
        return {
          'primaryColor': 0xff2367f6, // Blue theme for client
          'accentColor': 0xff022c41,
          'showWatermark': true,
          'watermarkText': 'CLIENT'
        };
      case classic:
      default:
        return {
          'primaryColor': 0xff58c2c4, // Teal theme for classic
          'accentColor': 0xff022c41,
          'showWatermark': false,
          'watermarkText': ''
        };
    }
  }
  
  // Feature flags based on variant
  static Map<String, bool> get features {
    switch (_appVariant) {
      case client:
        return {
          'advancedReporting': true,
          'customDashboard': true,
          'premiumSupport': true,
          'bulkOperations': true,
          'analyticsInsights': true,
        };
      case classic:
      default:
        return {
          'advancedReporting': false,
          'customDashboard': false,
          'premiumSupport': false,
          'bulkOperations': false,
          'analyticsInsights': false,
        };
    }
  }
  
  // API configuration (if different endpoints needed)
  static Map<String, String> get apiConfig {
    // Both versions use the same API for now
    // but this allows for different endpoints if needed in the future
    return {
      'baseUrl': 'https://gfmgems.globalfm.com.my',
      'apiVersion': 'v1',
      'timeout': '30000',
    };
  }
  
  // Debug information
  static void printConfig() {
    print('=== GEMS App Configuration ===');
    print('Variant: $_appVariant');
    print('Display Name: ${appDisplayName}');
    print('Subtitle: ${appSubtitle}');
    print('Features: ${features}');
    print('Theme: ${themeConfig}');
    print('===============================');
  }
}
