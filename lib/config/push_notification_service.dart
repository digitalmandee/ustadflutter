import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterustad/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    print("📩 Background Message Received");
    print("Message ID: ${message.messageId}");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Data: ${message.data}");
  }
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'Used for important notifications.',
        importance: Importance.high,
      );

  Future<void> initialize({
    required void Function(Map<String, dynamic> data) onNotificationTap,
  }) async {
    if (_isInitialized) return;

    await _requestPermission();
    await _setupLocalNotifications(onNotificationTap);
    await getDeviceToken();

    _listenTokenRefresh();
    _listenForegroundMessages();
    _listenNotificationClicks(onNotificationTap);

    _isInitialized = true;
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print("🔔 Notification permission: ${settings.authorizationStatus}");
    }

    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: false,
            badge: false,
            sound: false,
          );
    }
  }

  Future<void> _setupLocalNotifications(
    void Function(Map<String, dynamic> data) onNotificationTap,
  ) async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
          macOS: iosSettings,
        );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == null || response.payload!.isEmpty) return;

        try {
          final Map<String, dynamic> data = Map<String, dynamic>.from(
            jsonDecode(response.payload!),
          );

          onNotificationTap(data);
        } catch (e) {
          if (kDebugMode) {
            print("❌ Local notification payload error: $e");
          }
        }
      },
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  Future<String?> getDeviceToken() async {
    try {
      if (Platform.isIOS) {
        final apnsToken = await _waitForAPNSToken();

        if (apnsToken == null) {
          if (kDebugMode) {
            print("⚠️ APNs token not ready. FCM token not requested.");
          }
          return null;
        }

        if (kDebugMode) {
          print("🍎 APNs Token: $apnsToken");
        }
      }

      final fcmToken = await _messaging.getToken();

      if (fcmToken != null && fcmToken.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("fcm_token", fcmToken);

        if (kDebugMode) {
          print("✅ FCM Token: $fcmToken");
        }
      }

      return fcmToken;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error getting FCM token: $e");
      }
      return null;
    }
  }

  Future<String?> _waitForAPNSToken() async {
    String? apnsToken;

    for (int i = 0; i < 15; i++) {
      apnsToken = await _messaging.getAPNSToken();

      if (apnsToken != null && apnsToken.isNotEmpty) {
        return apnsToken;
      }

      await Future.delayed(const Duration(milliseconds: 700));
    }

    return null;
  }

  void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("fcm_token", newToken);

      if (kDebugMode) {
        print("🔁 FCM token refreshed: $newToken");
      }
    });
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title =
          message.notification?.title ??
          message.data["title"]?.toString() ??
          message.data["Title"]?.toString();

      final body =
          message.notification?.body ??
          message.data["body"]?.toString() ??
          message.data["Body"]?.toString();

      if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
        if (kDebugMode) {
          print("⚠️ Notification has no title/body: ${message.data}");
        }
        return;
      }

      _localNotificationsPlugin.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    });
  }

  void _listenNotificationClicks(
    void Function(Map<String, dynamic> data) onNotificationTap,
  ) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("📲 Notification tapped from background");
      }

      onNotificationTap(message.data);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        if (kDebugMode) {
          print("📲 Notification tapped from terminated state");
        }

        onNotificationTap(message.data);
      }
    });
  }

  Future<void> deleteToken() async {
    try {
      if (Platform.isIOS) {
        await _waitForAPNSToken();
      }

      await _messaging.deleteToken();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("fcm_token");

      if (kDebugMode) {
        print("✅ FCM token deleted");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ FCM delete token error: $e");
      }
    }
  }
}
