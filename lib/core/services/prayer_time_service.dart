import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimeService {
  static const double _defaultLat = 23.8103;
  static const double _defaultLng = 90.4125;

  static Map<String, DateTime>? _cachedTimes;
  static DateTime? _cacheDate;

  static Future<Map<String, DateTime>> getTodayTimes() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_cachedTimes != null && _cacheDate == today) {
      return _cachedTimes!;
    }

    double lat = _defaultLat;
    double lng = _defaultLng;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return _getFallbackTimes(now, today);
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          return _getFallbackTimes(now, today);
        }
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );
      lat = position.latitude;
      lng = position.longitude;
    } catch (_) {
      return _getFallbackTimes(now, today);
    }

    final coordinates = Coordinates(lat, lng);
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;
    final prayerTimes = PrayerTimes(
      coordinates,
      DateComponents.from(now),
      params,
    );

    final result = <String, DateTime>{};
    final times = <String, DateTime?>{
      'fajr': prayerTimes.fajr,
      'dhuhr': prayerTimes.dhuhr,
      'asr': prayerTimes.asr,
      'maghrib': prayerTimes.maghrib,
      'isha': prayerTimes.isha,
    };

    times.forEach((key, time) {
      if (time != null && time.isAfter(now)) {
        result[key] = time;
      }
    });

    _cachedTimes = result;
    _cacheDate = today;
    return result;
  }

  static Map<String, DateTime> _getFallbackTimes(DateTime now, DateTime today) {
    return {
      'fajr': DateTime(today.year, today.month, today.day, 5, 15).isAfter(now)
          ? DateTime(today.year, today.month, today.day, 5, 15)
          : DateTime(today.year, today.month, today.day + 1, 5, 15),
      'dhuhr': DateTime(today.year, today.month, today.day, 12, 30).isAfter(now)
          ? DateTime(today.year, today.month, today.day, 12, 30)
          : DateTime(today.year, today.month, today.day + 1, 12, 30),
      'asr': DateTime(today.year, today.month, today.day, 16, 0).isAfter(now)
          ? DateTime(today.year, today.month, today.day, 16, 0)
          : DateTime(today.year, today.month, today.day + 1, 16, 0),
      'maghrib':
          DateTime(today.year, today.month, today.day, 18, 0).isAfter(now)
          ? DateTime(today.year, today.month, today.day, 18, 0)
          : DateTime(today.year, today.month, today.day + 1, 18, 0),
      'isha': DateTime(today.year, today.month, today.day, 20, 0).isAfter(now)
          ? DateTime(today.year, today.month, today.day, 20, 0)
          : DateTime(today.year, today.month, today.day + 1, 20, 0),
    };
  }
}
