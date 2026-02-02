import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustaad/Providers/Chat/all_chat_provider.dart';
import 'package:ustaad/Providers/Contracts/contract_provider.dart';
import 'package:ustaad/Providers/Parent%20Side/dashboard_provider.dart';
import 'package:ustaad/Providers/Parent%20Side/get_tutors_provider.dart';
import 'package:ustaad/Providers/Tutor%20Side/location_provider.dart';
import 'package:ustaad/Providers/Parent%20Side/parent_profile_provider.dart';
import 'package:ustaad/Providers/Profile%20Setting/profile_setting_prov.dart';
import 'package:ustaad/Providers/Tutor%20Side/subject_cost_provider.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_about_provider.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_dashboard_provider.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_education_provider.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_exp_provider.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_veirfy_provider.dart';
import 'package:ustaad/Providers/notification/notification_provider.dart';
import 'package:ustaad/config/keys/global.dart';
import 'package:ustaad/firebase_options.dart';
import 'package:ustaad/splash_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Used for important notifications.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> setupFlutterNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting();
  await setupFlutterNotifications();
  if (Platform.isAndroid) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  }
  await getPrefData();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _requestPermission();
    _initFCM();
  }

  void _requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission();
    if (kDebugMode) {
      print('🔔 Permission granted: ${settings.authorizationStatus}');
    }
  }

  void _initFCM() async {
    String? token = await FirebaseMessaging.instance.getToken();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('fcm_token', token ?? '');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // print('🚀 Notification clicked: ${message.data}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FileProvider()),
        ChangeNotifierProvider(create: (_) => ExperienceProvider(context)),
        ChangeNotifierProvider(create: (_) => AboutProvider(context)),
        ChangeNotifierProvider(create: (_) => EducationProvider(context)),
        ChangeNotifierProvider(create: (_) => AllChatProvider(context)),
        ChangeNotifierProvider(create: (_) => CostSettingProvider(context)),
        ChangeNotifierProvider(create: (_) => LocationProvider(context)),
        ChangeNotifierProvider(create: (_) => GetTutorsProvider(context)),
        ChangeNotifierProvider(create: (_) => ParentProfileProvider(context)),
        ChangeNotifierProvider(create: (_) => TutorDashBoardProvider(context)),
        ChangeNotifierProvider(create: (_) => ParentDashboardProvider(context)),
        ChangeNotifierProvider(create: (_) => ContractProvider(context)),
        ChangeNotifierProvider(
            create: (_) => TutorEditProfileProvider(context)),
        ChangeNotifierProvider(create: (_) => NotificationProvider(context)),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'InstrumentSans',
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        title: 'Ustaad',
        home: const SplashScreen(),
      ),
    );
  }
}
