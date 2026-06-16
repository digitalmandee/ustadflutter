import 'dart:developer' as dev;
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutterustad/Providers/Chat/all_chat_provider.dart';
import 'package:flutterustad/Providers/Contracts/contract_provider.dart';
import 'package:flutterustad/Providers/Parent%20Side/dashboard_provider.dart';
import 'package:flutterustad/Providers/Parent%20Side/get_tutors_provider.dart';
import 'package:flutterustad/Providers/Parent%20Side/parent_profile_provider.dart';
import 'package:flutterustad/Providers/Profile%20Setting/profile_setting_prov.dart';
import 'package:flutterustad/Providers/Tutor%20Side/location_provider.dart';
import 'package:flutterustad/Providers/Tutor%20Side/subject_cost_provider.dart';
import 'package:flutterustad/Providers/Tutor%20Side/tutor_about_provider.dart';
import 'package:flutterustad/Providers/Tutor%20Side/tutor_dashboard_provider.dart';
import 'package:flutterustad/Providers/Tutor%20Side/tutor_education_provider.dart';
import 'package:flutterustad/Providers/Tutor%20Side/tutor_exp_provider.dart';
import 'package:flutterustad/Providers/Tutor%20Side/tutor_veirfy_provider.dart';
import 'package:flutterustad/Providers/notification/notification_provider.dart';
import 'package:flutterustad/config/keys/global.dart';
import 'package:flutterustad/config/push_notification_service.dart';
import 'package:flutterustad/firebase_options.dart';
import 'package:flutterustad/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  dev.log("MAIN LOG: main() started");

  try {
    dev.log("MAIN LOG: Initializing Firebase...");

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    dev.log("MAIN LOG: Firebase initialized successfully");

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    dev.log("MAIN LOG: Firebase background handler registered");

    await _debugFCMDirectCheck();

    dev.log("MAIN LOG: Initializing PushNotificationService...");

    await PushNotificationService.instance.initialize(
      onNotificationTap: _handleNotificationClick,
    );

    dev.log("MAIN LOG: PushNotificationService initialized successfully");

    await initializeDateFormatting();

    dev.log("MAIN LOG: Date formatting initialized");
  } catch (e) {
    dev.log("MAIN ERROR: Firebase/notification initialization error: $e");
  }

  if (!kIsWeb && Platform.isAndroid) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
    dev.log("MAIN LOG: Android WebView initialized");
  }

  try {
    dev.log("MAIN LOG: Calling getPrefData...");
    await getPrefData();
    dev.log("MAIN LOG: getPrefData completed");
  } catch (e) {
    dev.log("MAIN ERROR: getPrefData error: $e");
  }

  dev.log("MAIN LOG: runApp starting");

  runApp(
    ScreenUtilInit(
      designSize: const Size(390, 860),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return const MyApp();
      },
    ),
  );
}

Future<void> _debugFCMDirectCheck() async {
  dev.log("========== DIRECT FCM CHECK START ==========");

  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  dev.log("DIRECT FCM: Permission = ${settings.authorizationStatus}");
  dev.log("DIRECT FCM: Alert = ${settings.alert}");
  dev.log("DIRECT FCM: Badge = ${settings.badge}");
  dev.log("DIRECT FCM: Sound = ${settings.sound}");

  await messaging.setAutoInitEnabled(true);

  if (Platform.isIOS) {
    dev.log("DIRECT FCM: iOS detected. Waiting for APNs token...");

    String? apnsToken;

    for (int i = 1; i <= 20; i++) {
      apnsToken = await messaging.getAPNSToken();

      dev.log("DIRECT FCM: APNs attempt $i = ${apnsToken ?? 'NULL'}");

      if (apnsToken != null && apnsToken.isNotEmpty) {
        break;
      }

      await Future.delayed(const Duration(milliseconds: 700));
    }

    if (apnsToken == null || apnsToken.isEmpty) {
      dev.log("DIRECT FCM ERROR: APNs token is still NULL");
      dev.log(
        "DIRECT FCM HINT: Check Xcode Push Notifications, Background Modes, Remote notifications, APNs key, and Bundle ID.",
      );
      return;
    }
  }

  final fcmToken = await messaging.getToken();

  dev.log("DIRECT FCM: FCM token = ${fcmToken ?? 'NULL'}");
  dev.log("========== DIRECT FCM CHECK END ==========");
}

void _handleNotificationClick(Map<String, dynamic> data) {
  dev.log("MAIN LOG: Notification click data: $data");

  if (data['type'] == 'chat') {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
    );
  }
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
    dev.log("APP LOG: MyApp initState called");
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
          create: (_) => TutorEditProfileProvider(context),
        ),
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
        builder: (context, child) {
          return SafeArea(
            top: false,
            bottom: Platform.isAndroid,
            left: true,
            right: true,
            child: child!,
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}
