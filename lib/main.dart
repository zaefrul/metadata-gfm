import 'dart:io';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter/material.dart';
import 'package:GEMS/controller/Storekeeper/utils/bloc/bloc_technician.dart';
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
import 'controller/WorkOrder/complaintSearch.dart';
import 'controller/WorkOrder/workorder.dart';
import 'controller/Storekeeper/route/engineer/route_engineer.dart';
import 'controller/Storekeeper/route/procurement/route_procurement.dart';
import 'controller/Storekeeper/route/storekeeper/homepage.dart' as store_keeper_home;
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

import 'controller/login.dart';
import 'controller/Profile/profile.dart';
import 'controller/Homepage/resetPassword.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:GEMS/model/complaint.dart';

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;
int alertCount = 0;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

late FirebaseMessaging? _messaging;

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

  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization failed: ${e.toString()}");
    // Continue without Firebase if it fails
  }

  // Instantiate Firebase Messaging.
  try {
    _messaging = FirebaseMessaging.instance;
    print("Firebase Messaging initialized successfully");
  } catch (e) {
    print("Firebase Messaging initialization failed: ${e.toString()}");
    // Continue without Firebase messaging if it fails
  }

  // Request permission on iOS.
  if (_messaging != null) {
    try {
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      // **Make sure to grab APNS token immediately on iOS:**
      if (Platform.isIOS) {
        try {
          String? apnsToken = await _messaging!.getAPNSToken();
          print('🪶 APNS token: $apnsToken');
        } catch (e) {
          debugPrint('⚠️ getAPNSToken failed: $e');
        }
      }

      await _messaging!.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else {
        print('User declined or has not accepted permission');
      }

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen((RemoteMessage event) {
        showNotification(event).catchError((err) => debugPrint('Notification error: $err'));
      });
    } catch (e) {
      print("Firebase messaging setup failed: ${e.toString()}");
    }
  } else {
    print("Firebase Messaging is not available - continuing without push notifications");
  }

  if (Platform.isIOS || Platform.isAndroid) {
    await setupFlutterNotifications();
  }

  runApp(MyApp(navigatorKey: navigatorKey));
}

Future<void> showNotification(RemoteMessage payload) async {
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initialSetting = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();
  await plugin.initialize(initialSetting);

  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'default_notification_channel_id',
    'Notification',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    icon: initializationSettingsAndroid.defaultIcon,
  );
  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidDetails);

  await plugin.show(
      alertCount,
      payload.notification?.title ?? '',
      payload.notification?.body ?? '',
      platformChannelSpecifics);

  alertCount++;
}

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Make sure to initialize Firebase before using it in the background.
  print('Handling a background message ${message.messageId}');
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  if ((Platform.isIOS || Platform.isAndroid) && notification != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'launch_background',
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyApp({super.key, required this.navigatorKey});

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
          primaryTextTheme:
              TextTheme(titleLarge: TextStyle(color: colorTheme3)),
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
      title: "GEMS 2.0",
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
    );
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
            builder: (context) => Login(), settings: settings);
      case "/homepage":
        return MaterialPageRoute(
            builder: (context) => main_home.Homepage(), settings: settings);
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
        final String value = settings.arguments as String;
        return MaterialPageRoute(
            builder: (context) => MaterialEdit(value), settings: settings);
      case routeTechnician:
        if (settings.arguments != null) {
          return MaterialPageRoute(
              builder: (ctx) =>
                  RouteTechnician(value: settings.arguments as BlocTechnician), settings: settings);
        }
        return MaterialPageRoute(
            builder: (ctx) => RouteTechnician(value: settings.arguments as BlocTechnician), settings: settings);
      case routeTechnicianDetail:
        return MaterialPageRoute(
            builder: (ctx) =>
                RouteTechnicianDetail(item: settings.arguments as Item), settings: settings);
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
            builder: (ctx) => MaterialInfo(value: settings.arguments as ComplaintDType), settings: settings);
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
                  value: settings.arguments as dynamic, // Replace 'dynamic' with the correct type if known
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
            builder: (ctx) => MaterialRequestScreen(value: settings.arguments as dynamic), settings: settings);
      case routeDashboard:
        return MaterialPageRoute(
            builder: (ctx) => store_keeper_home.Homepage(), settings: settings);
      case routeDetails:
        return MaterialPageRoute(
            builder: (ctx) => MaterialDetails(id: settings.arguments as String), settings: settings);
      case routeCheckInInfo:
        return MaterialPageRoute(
            builder: (ctx) => CheckinDetails(key: UniqueKey(), id: settings.arguments as dynamic), settings: settings);
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
            // builder: (_) => Placeholder(), settings: settings); // Replace Placeholder with the correct widget if known
      default:
        return MaterialPageRoute(builder: (ctx) => ProcumentHomepage());
    }
  }
}
