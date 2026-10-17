import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:posthog_flutter/posthog_flutter.dart' as posthog;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import 'prayer_time_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Timer? _midnightTimer;

  static const int _fajrId = 1;
  static const int _dhuhrId = 2;
  static const int _asrId = 3;
  static const int _maghribId = 4;
  static const int _ishaId = 5;
  static const int _nightDhikrId = 6;

  static Future<void> initialize() async {
    if (kIsWeb) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createChannels();
    _startMidnightTimer();
  }

  static Future<void> requestPermissions() async {
    if (kIsWeb) return;

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, sound: true, badge: false);
  }

  static Future<void> _createChannels() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return;
    final channels = <AndroidNotificationChannel>[
      const AndroidNotificationChannel(
        'fajr_channel',
        'ফজরের সালাত',
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        'dhuhr_channel',
        'যোহরের সালাত',
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        'asr_channel',
        'আসরের সালাত',
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        'maghrib_channel',
        'মাগরিবের সালাত',
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        'isha_channel',
        'ইশার সালাত',
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        'night_dhikr_channel',
        'ঘুমের আগে যিকির',
        importance: Importance.high,
      ),
    ];
    for (final ch in channels) {
      await androidPlugin.createNotificationChannel(ch);
    }
  }

  static Future<void> scheduleAll(Map<String, dynamic> settingsMap) async {
    if (kIsWeb) return;

    try {
      await _plugin.cancelAll();
      final prayerTimes = await PrayerTimeService.getTodayTimes();

      if (settingsMap['fajr'] == true && prayerTimes.containsKey('fajr')) {
        await _schedule(
          'fajr_channel',
          _fajrId,
          'ফজরের সালাত',
          'ফজরের সালাতের সময় হয়েছে',
          prayerTimes['fajr']!,
        );
      }
      if (settingsMap['dhuhr'] == true && prayerTimes.containsKey('dhuhr')) {
        await _schedule(
          'dhuhr_channel',
          _dhuhrId,
          'যোহরের সালাত',
          'যোহরের সালাতের সময় হয়েছে',
          prayerTimes['dhuhr']!,
        );
      }
      if (settingsMap['asr'] == true && prayerTimes.containsKey('asr')) {
        await _schedule(
          'asr_channel',
          _asrId,
          'আসরের সালাত',
          'আসরের সালাতের সময় হয়েছে',
          prayerTimes['asr']!,
        );
      }
      if (settingsMap['maghrib'] == true &&
          prayerTimes.containsKey('maghrib')) {
        await _schedule(
          'maghrib_channel',
          _maghribId,
          'মাগরিবের সালাত',
          'মাগরিবের সালাতের সময় হয়েছে',
          prayerTimes['maghrib']!,
        );
      }
      if (settingsMap['isha'] == true && prayerTimes.containsKey('isha')) {
        await _schedule(
          'isha_channel',
          _ishaId,
          'ইশার সালাত',
          'ইশার সালাতের সময় হয়েছে',
          prayerTimes['isha']!,
        );
      }
      if (settingsMap['nightDhikr'] == true) {
        final timeStr = settingsMap['nightDhikrTime'] ?? '22:30';
        final parts = timeStr.split(':');
        final now = DateTime.now();
        var dt = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
        if (dt.isBefore(now)) dt = dt.add(const Duration(days: 1));
        await _schedule(
          'night_dhikr_channel',
          _nightDhikrId,
          'ঘুমের আগে যিকির',
          'ঘুমানোর আগে যিকির ও দু\'আ পড়ুন',
          dt,
        );
      }
    } catch (e) {
      debugPrint('Notification scheduling failed: $e');
    }
  }

  static Future<void> _schedule(
    String channelId,
    int id,
    String title,
    String body,
    DateTime time,
  ) async {
    try {
      final scheduled = tz.TZDateTime.from(time, tz.local);
      if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          channelDescription: title,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduled,
          details,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {
        // alarmClock needs SCHEDULE_EXACT_ALARM; fall back to inexact.
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduled,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      debugPrint('Notification schedule failed: $e');
    }
  }

  static void _startMidnightTimer() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);

    _midnightTimer = Timer(duration, () async {
      await rescheduleDaily();
      _startMidnightTimer();
    });
  }

  static Future<void> rescheduleDaily() async {
    if (kIsWeb) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsMap = {
        'fajr': prefs.getBool('notif_fajr'),
        'dhuhr': prefs.getBool('notif_dhuhr'),
        'asr': prefs.getBool('notif_asr'),
        'maghrib': prefs.getBool('notif_maghrib'),
        'isha': prefs.getBool('notif_isha'),
        'nightDhikr': prefs.getBool('notif_nightDhikr'),
        'nightDhikrTime': prefs.getString('notif_nightDhikrTime'),
      };
      await scheduleAll(settingsMap);
    } catch (_) {}
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // PostHog is not configured in this app yet — never let analytics
    // crash the notification callback.
    try {
      final channelId = response.payload;
      posthog.Posthog().capture(
        eventName: 'notification_tapped',
        properties: {'type': channelId ?? 'unknown'},
      );
    } catch (_) {}
  }
}
