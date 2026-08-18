import 'dart:io';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc_technician.dart';
import 'package:GEMS/utils/biometric_lock_manager.dart';
import 'controller/Attendance/attendance.dart' as main_attendance;
import 'controller/Homepage/signature.dart';
import 'controller/Leaderboard/leaderboard.dart';
import 'controller/PPM/PMaintenance.dart';
import 'controller/PPM/routine_inspection.dart';
import 'controller/PPM/search.dart';
import 'controller/PPM/ri_search.dart';
import 'controller/Storekeeper/route/storekeeper/checkin_add_material.dart';
import 'controller/Storekeeper/route/storekeeper/checkin_request.dart';
import 'controller/Storekeeper/route/technician/route_technician_detail.dart';
import 'controller/Storekeeper/utils/constant.dart';
import 'controller/TaskMonitoring/taskMonitoring.dart';
import 'controller/Homepage/homepage.dart' as main_home;
import 'controller/Homepage/support.dart';
import 'controller/Utilities/Homepage.dart' as utilities_home;
import 'controller/WorkOrder/complaintMaterial.dart';
import 'controller/WorkOrder/material_arguments.dart';
import 'controller/WorkOrder/complaintSearch.dart';
import 'controller/WorkOrder/workorder.dart';
import 'controller/Storekeeper/route/engineer/route_engineer.dart';
import 'controller/Storekeeper/route/procurement/route_procurement.dart';
import 'controller/Storekeeper/route/storekeeper/homepage.dart'
    as store_keeper_home;
import 'controller/Storekeeper/route/storekeeper/route_MR.dart';
import 'controller/Storekeeper/route/procurement/route_PO.dart';
import 'controller/Storekeeper/route/storekeeper/route_PR.dart';
import 'controller/Storekeeper/route/storekeeper/route_material_info.dart';
import 'controller/Storekeeper/route/storekeeper/route_register.dart';
import 'controller/Storekeeper/route/technician/route_technician.dart';
// import 'controller/Storekeeper/utils/bloc/bloc_technician.dart';
import 'controller/Storekeeper/route/storekeeper/checkin_list.dart';
import 'controller/Storekeeper/route/storekeeper/product_details.dart';
import 'controller/Storekeeper/route/storekeeper/stockIn_list.dart';
import 'controller/ReturnItem/return_item_list.dart';
import 'controller/ReturnItem/return_item_detail.dart';
import 'controller/ReturnItem/return_confirm_list.dart';
import 'controller/ReturnItem/return_confirm_detail.dart';
import 'controller/ReturnItem/api_test_screen.dart';
import 'view/secret_debug_menu.dart';

import 'controller/login.dart';
import 'controller/Profile/profile.dart';
import 'controller/Homepage/resetPassword.dart';
import 'controller/Notifications/notifications.dart';
import 'service/notification_service.dart';
import 'utils/network.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:GEMS/model/complaint.dart';
import 'package:GEMS/model/return_ticket_models.dart';
import 'package:GEMS/config/app_config.dart';
import 'package:GEMS/model/user.dart';
import 'package:local_auth/local_auth.dart';

import 'utils/auth_secure_storage.dart';
import 'utils/debug_log_service.dart';
import 'utils/location_helper.dart';
import 'view/debug_log_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  // Helper function to instantiate MyApp
  // MyApp material(String init) => const MyApp();

  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  final originalDebugPrint = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) {
      DebugLogService.instance.add(message);
    }
    originalDebugPrint(message, wrapWidth: wrapWidth);
  };

  // Print app configuration for debugging
  AppConfig.printConfig();

  try {
    await Firebase.initializeApp();
    debugPrint("Firebase initialized successfully");
    await NotificationService.initialize(navigatorKey: navigatorKey);
  } catch (e) {
    debugPrint("Firebase initialization failed: ${e.toString()}");
  }

  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyApp({super.key, required this.navigatorKey});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _biometricAvailable = false;
  bool _isAuthenticating = false;
  bool _shouldLockOnResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepareBiometric();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Don't set lock flag if we're suppressing (e.g., opening camera/file picker)
      // Use shouldSuppress() here to check without resetting the flag
      if (!BiometricLockManager.shouldSuppress()) {
        _shouldLockOnResume = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      // Reset suppression flag if it was set (picker operation completed)
      if (BiometricLockManager.shouldSuppressAndReset()) {
        // Suppression was active, don't lock
        _shouldLockOnResume = false;
      }
      
      // Handle biometric lock if needed
      if (_shouldLockOnResume) {
        _handleResume();
      }
      _refreshLocationSession();
    }
  }

  Future<void> _refreshLocationSession() async {
    try {
      await User.getPrefUser;
      await resolveDeviceLocation(forceRefresh: true);
    } catch (_) {
      // Not logged in, or GPS unavailable — submit-time check is the gate.
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Avenir",
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // Replace with a constant color
        ),
        primaryColor: colorTheme3,
        primaryTextTheme: TextTheme(titleLarge: TextStyle(color: colorTheme3)),
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          // or replace both with your custom one:
          // TargetPlatform.android: _MyFadeBuilder(),
          // TargetPlatform.iOS: _MyFadeBuilder(),
        }),
      ),
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      title: AppConfig.appDisplayName,
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
      onGenerateRoute: _generateRoute,
      navigatorKey: widget.navigatorKey,
      navigatorObservers: [routeObserver],
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        NetworkSource? preselected;
        final loginArgs = settings.arguments;
        if (loginArgs is LoginArguments) {
          preselected = loginArgs.preselectedSource;
        } else if (loginArgs is NetworkSource) {
          preselected = loginArgs;
        }
        return MaterialPageRoute(
            builder: (context) => Login(preselectedSource: preselected),
            settings: settings);
      case "/homepage":
        return MaterialPageRoute(
            builder: (context) => main_home.Homepage(), settings: settings);
      case NotificationsScreen.routeName:
        return MaterialPageRoute(
            builder: (context) => const NotificationsScreen(),
            settings: settings);
      case "/ppm":
        return MaterialPageRoute(
            builder: (context) => PreventiveMaintenance(), settings: settings);
      case routeRoutineInspection:
        return MaterialPageRoute(
            builder: (context) => RoutineInspection(), settings: settings);
      case "/workorder":
        return MaterialPageRoute(
            builder: (context) => WorkOrderView(), settings: settings);
      case "/support":
        return MaterialPageRoute(
            builder: (context) => Support(), settings: settings);
      case SearchComplaint.routeName:
        return MaterialPageRoute(
            builder: (context) => SearchComplaint(), settings: settings);
      case Search.routeName:
        return MaterialPageRoute(
            builder: (context) => Search(), settings: settings);
      case SearchRI.routeName:
        return MaterialPageRoute(
            builder: (context) => SearchRI(), settings: settings);
      case "/profile":
        return MaterialPageRoute(
            builder: (context) => Profile(), settings: settings);
      case ResetPassword.routeName:
        return MaterialPageRoute(
            builder: (context) => ResetPassword(), settings: settings);
      case "/monitoring":
        return MaterialPageRoute(
            builder: (context) => TaskMonitoringScreen(), settings: settings);
      case routeMaterial:
        final args = settings.arguments;
        if (args is! MaterialEditArguments) {
          throw ArgumentError('routeMaterial expects MaterialEditArguments');
        }
        return MaterialPageRoute<bool?>(
            builder: (context) => MaterialEdit(args), settings: settings);
      case routeTechnician:
        if (settings.arguments != null) {
          return MaterialPageRoute(
              builder: (ctx) =>
                  RouteTechnician(value: settings.arguments as BlocTechnician),
              settings: settings);
        }
        return MaterialPageRoute(
            builder: (ctx) =>
                RouteTechnician(value: settings.arguments as BlocTechnician),
            settings: settings);
      case routeTechnicianDetail:
        return MaterialPageRoute(
            builder: (ctx) =>
                RouteTechnicianDetail(item: settings.arguments as Item),
            settings: settings);
      case routeEngineer:
        final value = BlocTechnician.from(settings.arguments as BlocTechnician);
        return MaterialPageRoute(
            builder: (ctx) => RouteEngineer(value: value), settings: settings);
      case routeInventory:
        return MaterialPageRoute(
            builder: (ctx) => store_keeper_home.Homepage(), settings: settings);
      case routeCheckIn:
        return MaterialPageRoute(
            builder: (ctx) => store_keeper_home.Homepage(), settings: settings);
      case routeCheckOut:
        return MaterialPageRoute(
            builder: (ctx) => store_keeper_home.Homepage(), settings: settings);
      case routeMaterialInfo:
        return MaterialPageRoute(
            builder: (ctx) =>
                MaterialInfo(value: settings.arguments as ComplaintDType),
            settings: settings);
      case routeMaterialCheckinRequest:
        return MaterialPageRoute(
            builder: (ctx) => CheckinRequest(), settings: settings);
      case routeRegisterItem:
        return MaterialPageRoute(
            builder: (ctx) => RegisterItem(), settings: settings);
      case routePurchaseRequest:
        return MaterialPageRoute(
            builder: (ctx) => PurchaseRequest(), settings: settings);
      case routePurchaseOrder:
        return MaterialPageRoute(
            builder: (ctx) => PurchaseOrder(), settings: settings);
      case routeMateralRequest:
        return MaterialPageRoute(
            builder: (ctx) => MaterialRequestScreen(
                  value: settings.arguments
                      as dynamic, // Replace 'dynamic' with the correct type if known
                  isApproval: true,
                ),
            settings: settings);
      case routeMaterialRequestView:
        return MaterialPageRoute(
            builder: (ctx) => MaterialRequestScreen(
                  value: settings.arguments as dynamic,
                  isCheckout: true,
                ),
            settings: settings);
      case routeStockRequest:
        return MaterialPageRoute(
            builder: (ctx) =>
                MaterialRequestScreen(value: settings.arguments as dynamic),
            settings: settings);
      case routeDashboard:
        return MaterialPageRoute(
            builder: (ctx) => store_keeper_home.Homepage(), settings: settings);
      case routeDetails:
        return MaterialPageRoute(
            builder: (ctx) => MaterialDetails(id: settings.arguments as String),
            settings: settings);
      case routeCheckInInfo:
        return MaterialPageRoute(
            builder: (ctx) => CheckinDetails(
                key: UniqueKey(), id: settings.arguments as dynamic),
            settings: settings);
      case routeStockIn:
        return MaterialPageRoute(
            builder: (ctx) => StockInList(), settings: settings);
      case routeAddStockIn:
        return MaterialPageRoute(
            builder: (ctx) => CheckinAdd(), settings: settings);
      case routeUtilities:
        return MaterialPageRoute(
            builder: (_) => utilities_home.UtilitiesHome(), settings: settings);
      case routeSignature:
        return MaterialPageRoute(
          builder: (_) => SignatureView(
            id: settings.arguments as String,
            // result: "",
            // checkpoint: ""
          ),
          settings: settings,
        );
      case routeLeaderboard:
        return MaterialPageRoute(
            builder: (_) => LeaderboardView(), settings: settings);
      case routeAttendance:
        return MaterialPageRoute(
            builder: (_) => main_attendance.Dashboard(), settings: settings);
      case DebugLogScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => const DebugLogScreen(), settings: settings);
      case '/return-item-list':
        return MaterialPageRoute(
            builder: (_) => ReturnItemList(), settings: settings);
      case '/return-item-detail':
        final args = settings.arguments;
        if (args is! ReturnPartGroup) {
          throw ArgumentError('/return-item-detail expects ReturnPartGroup argument');
        }
        return MaterialPageRoute(
            builder: (_) => ReturnItemDetail(group: args), settings: settings);
      case '/return-confirm-list':
        return MaterialPageRoute(
            builder: (_) => ReturnConfirmList(), settings: settings);
      case '/return-confirm-detail':
        final args = settings.arguments;
        if (args is! String) {
          throw ArgumentError('/return-confirm-detail expects String returnId argument');
        }
        return MaterialPageRoute(
            builder: (_) => ReturnConfirmDetail(returnId: args), settings: settings);
      case '/api-test':
        return MaterialPageRoute(
            builder: (_) => ApiTestScreen(), settings: settings);
      case '/secret-debug-menu':
        return MaterialPageRoute(
            builder: (_) => SecretDebugMenu(), settings: settings);
      // builder: (_) => Placeholder(), settings: settings); // Replace Placeholder with the correct widget if known
      default:
        return MaterialPageRoute(builder: (ctx) => ProcumentHomepage());
    }
  }

  Future<void> _prepareBiometric() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!mounted) return;
      setState(() {
        _biometricAvailable = supported && canCheck;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _biometricAvailable = false;
      });
      debugPrint('Biometric availability check failed: $e');
    }
  }

  Future<void> _handleResume() async {
    if (_isAuthenticating) return;

    if (!_biometricAvailable) {
      _shouldLockOnResume = false;
      return;
    }

    final enabled = await AuthSecureStorage.isEnabled();
    if (!enabled) {
      _shouldLockOnResume = false;
      return;
    }

    final creds = await AuthSecureStorage.readCredentials();
    if (creds == null) {
      _shouldLockOnResume = false;
      return;
    }

    var hasSession = true;
    try {
      await User.getPrefUser;
    } catch (_) {
      hasSession = false;
    }

    if (!hasSession) {
      _shouldLockOnResume = false;
      return;
    }

    if (_isLoginRouteActive()) {
      _shouldLockOnResume = false;
      return;
    }

    _isAuthenticating = true;
    try {
      BiometricLockManager.suppressNextLock();
      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Authenticate to continue using GEMS',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!didAuth) {
        await _lockApp();
        return;
      }

      _shouldLockOnResume = false;
    } catch (e) {
      debugPrint('Biometric authentication on resume failed: $e');
      await _lockApp();
    } finally {
      _isAuthenticating = false;
    }
  }

  bool _isLoginRouteActive() {
    final ctx = widget.navigatorKey.currentContext;
    if (ctx == null) return false;
    final route = ModalRoute.of(ctx);
    if (route == null) return false;
    return route.settings.name == "/";
  }

  Future<void> _lockApp() async {
    _shouldLockOnResume = false;
    await _logoutUser();
    final navigator = widget.navigatorKey.currentState;
    if (navigator == null) {
      return;
    }
    navigator.pushNamedAndRemoveUntil('/', (route) => false);
  }

  Future<void> _logoutUser() async {
    try {
      final raw = await User.getPrefUser;
      final user = User.fromMap(raw);
      await user.removeUser();
    } catch (e) {
      debugPrint('Failed to clear stored user during biometric lock: $e');
    }
  }
}
