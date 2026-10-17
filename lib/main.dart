import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  try {
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
  } catch (_) {
    // Keeps tz.local (UTC) — scheduling still works, never crashes.
  }
  await initializeDateFormatting('bn', null);

  try {
    await FirebaseService.initialize();
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  try {
    await NotificationService.initialize();
    await NotificationService.requestPermissions();
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }

  runApp(const ProviderScope(child: MuhasabatApp()));
}
