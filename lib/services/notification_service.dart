import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // no custom icon for now
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Channel for basic notifications',
          defaultColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelKey: 'scheduled_channel',
          channelName: 'Scheduled Notifications',
          channelDescription: 'Channel for scheduled notifications',
          defaultColor: Colors.green,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
      debug: true,
    );

    // Initialize FCM
    await initializeRemoteNotifications();

    // Request notification permissions
    await requestPermissions();
  }

  Future<void> initializeRemoteNotifications() async {
    await AwesomeNotificationsFcm().initialize(
      onFcmSilentDataHandle: onFcmSilentDataHandle,
      onFcmTokenHandle: onFcmTokenHandle,
      onNativeTokenHandle: onNativeTokenHandle,
      licenseKeys: null, // Add license key if available
      debug: true,
    );
  }

  Future<void> requestPermissions() async {
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  // FCM handlers
  @pragma('vm:entry-point')
  static Future<void> onFcmSilentDataHandle(FcmSilentData silentData) async {
    print('FCM SILENT DATA: ${silentData.toString()}');

    if (silentData.createdLifeCycle != NotificationLifeCycle.Foreground) {
      // Handle background/terminated silent data
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onFcmTokenHandle(String token) async {
    print('FCM TOKEN: $token');
    // Print to see the sent token to the server
  }

  @pragma('vm:entry-point')
  static Future<void> onNativeTokenHandle(String token) async {
    print('NATIVE TOKEN: $token');
    // Handle native token
  }

  // Local notification methods
  Future<void> showLoginSuccessNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: 'Login Successful',
        body: 'You have successfully logged in to Recipe App',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  // Add more notification methods here for different use cases
  Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'scheduled_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledDate),
    );
  }

  // Update the UserFcmToken method

  Future<void> updateUserFcmToken(String userId) async {
    try {
      // Get the current FCM token
      String token = await AwesomeNotificationsFcm().requestFirebaseAppToken();

      if (token.isNotEmpty) {
        // Update the token in Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'fcmToken': token},
        );

        print('FCM token updated for user: $userId');
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }
}
