import 'dart:io';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter/material.dart';
import 'package:gfm_gems/controller/Storekeeper/utils/bloc/bloc_technician.dart';
import 'controller/Attendance/attendance.dart';
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
import 'controller/Homepage/homepage.dart' as mainHome;
import 'controller/Homepage/support.dart';
import 'controller/Utilities/Homepage.dart';
import 'controller/WorkOrder/complaintMaterial.dart';
import 'controller/WorkOrder/complaintSearch.dart';
import 'controller/WorkOrder/workorder.dart';
import 'controller/Storekeeper/route/engineer/route_engineer.dart';
import 'controller/Storekeeper/route/procurement/route_procurement.dart';
import 'controller/Storekeeper/route/storekeeper/homepage.dart';
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

// import 'firebase_config.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;
int alertCount = 0;

FirebaseMessaging _messaging;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  material(init) => MyApp();

  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  try {
    // if (Platform.isIOS) {
    await Firebase.initializeApp();
    // } else if (Platform.isAndroid) {
    //   await Firebase.initializeApp(
    //       options: DefaultFirebaseConfig.platformOptions);
    // }
  } catch (e) {
    debugPrint(e.toString());
  }

  // 2. Instantiate Firebase Messaging
  _messaging = FirebaseMessaging.instance;

  // 3. On iOS, this helps to take the user permissions
  NotificationSettings settings = await _messaging.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );
  await _messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
    // TODO: handle the received notifications
  } else {
    print('User declined or has not accepted permission');
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    showNotification(event).catchError((err) => debugPrint(err.toString()));
  });

  if (Platform.isIOS || Platform.isAndroid) {
    await setupFlutterNotifications();
  }

  return runApp(material("/"));
}

Future<void> showNotification(RemoteMessage payload) async {
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('@mipmap/ic_launcher');
  // var initiallizationSettingsIOS = IOSInitializationSettings();
  var initialSetting = new InitializationSettings(
    android: initializationSettingsAndroid,
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initialSetting);

  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'default_notification_channel_id',
    'Notification',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    icon: initializationSettingsAndroid.defaultIcon,
  );
  // const iOSDetails = IOSNotificationDetails();
  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
      alertCount,
      payload.notification.title,
      payload.notification.body,
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

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification notification = message.notification;
  AndroidNotification android = message.notification?.android;
  if (notification != null &&
      android != null &&
      (Platform.isIOS || Platform.isAndroid)) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'launch_background',
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          fontFamily: "Avenir",
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: colorTheme3,
          ),
          primaryColor: colorTheme3,
          primaryTextTheme:
              TextTheme(headline6: TextStyle(color: colorTheme3))),
      localizationsDelegates: [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      title: "GEMS 2.0",
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
    );
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
            builder: (context) => Login(), settings: settings);
      case "/homepage":
        return MaterialPageRoute(
            builder: (context) => mainHome.Homepage(), settings: settings);
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
            builder: (context) => TaskMonitoring(), settings: settings);
      case routeMaterial:
        final String value = settings.arguments as String;
        return MaterialPageRoute(
            builder: (context) => MaterialEdit(value), settings: settings);
      case routeTechnician:
        if (settings.arguments != null)
          return MaterialPageRoute(
              builder: (ctx) => RouteTechnician(value: settings.arguments));
        return MaterialPageRoute(
            builder: (ctx) => RouteTechnician(), settings: settings);
      case routeTechnicianDetail:
        return MaterialPageRoute(
            builder: (ctx) => RouteTechnicianDetail(item: settings.arguments),
            settings: settings);
      case routeEngineer:
        final value = BlocTechnician.from(settings.arguments);
        return MaterialPageRoute(
            builder: (ctx) => RouteEngineer(value: value), settings: settings);
      case routeInventory:
        return MaterialPageRoute(
            builder: (ctx) => Homepage(), settings: settings);
      case routeCheckIn:
        return MaterialPageRoute(
            builder: (ctx) => Homepage(), settings: settings);
      case routeCheckOut:
        return MaterialPageRoute(
            builder: (ctx) => Homepage(), settings: settings);
      case routeMaterialInfo:
        return MaterialPageRoute(
            builder: (ctx) => MaterialInfo(value: settings.arguments),
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
            builder: (ctx) => MaterialRequest(
                  value: settings.arguments,
                  isApproval: true,
                ),
            settings: settings);
      case routeMaterialRequestView:
        return MaterialPageRoute(
            builder: (ctx) => MaterialRequest(
                  value: settings.arguments,
                  isCheckout: true,
                ),
            settings: settings);
      case routeStockRequest:
        return MaterialPageRoute(
            builder: (ctx) => MaterialRequest(value: settings.arguments),
            settings: settings);
      case routeDashboard:
        return MaterialPageRoute(
            builder: (ctx) => Homepage(), settings: settings);
      case routeDetails:
        return MaterialPageRoute(
            builder: (ctx) => MaterialDetails(settings.arguments),
            settings: settings);
      case routeCheckInInfo:
        return MaterialPageRoute(
            builder: (ctx) => CheckinDetails(id: settings.arguments),
            settings: settings);
      case routeStockIn:
        return MaterialPageRoute(
            builder: (ctx) => StockInList(), settings: settings);
      case routeAddStockIn:
        return MaterialPageRoute(
            builder: (ctx) => CheckinAdd(), settings: settings);
      case routeUtilities:
        return MaterialPageRoute(
            builder: (_) => UtilitiesHome(), settings: settings);
      case routeSignature:
        return MaterialPageRoute(
          builder: (_) => SignatureView(id: settings.arguments),
          settings: settings,
        );
      case routeLeaderboard:
        return MaterialPageRoute(
            builder: (_) => LeaderboardView(), settings: settings);
      case routeAttendance:
        return MaterialPageRoute(
            builder: (_) => Dashboard(), settings: settings);
      default:
        return MaterialPageRoute(builder: (ctx) => ProcumentHomepage());
    }
  }
}
