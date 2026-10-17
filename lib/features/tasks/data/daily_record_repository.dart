import 'package:firebase_database/firebase_database.dart';

import '../../../../core/models/daily_record.dart';
import '../../../../core/utils/date_utils.dart';

class DailyRecordRepository {
  final FirebaseDatabase? _databaseOverride;

  DailyRecordRepository({FirebaseDatabase? database})
    : _databaseOverride = database;

  FirebaseDatabase get _database {
    if (_databaseOverride != null) return _databaseOverride;
    return FirebaseDatabase.instance;
  }

  DatabaseReference _userRecordsRef(String userId) {
    return _database.ref('users/$userId/records');
  }

  Future<DailyRecord?> getRecord(String userId, DateTime date) async {
    final key = DateUtils.formatDateKey(date);
    final snapshot = await _userRecordsRef(userId).child(key).get();
    if (!snapshot.exists) return null;
    return DailyRecord.fromMap(
      Map<String, dynamic>.from(snapshot.value as Map),
    );
  }

  Future<void> saveRecord(String userId, DailyRecord record) async {
    final key = DateUtils.formatDateKey(record.date);
    await _userRecordsRef(userId).child(key).set(record.toMap());
  }

  Stream<DailyRecord?> watchRecord(String userId, DateTime date) {
    final key = DateUtils.formatDateKey(date);
    return _userRecordsRef(userId).child(key).onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return DailyRecord.fromMap(
        Map<String, dynamic>.from(event.snapshot.value as Map),
      );
    });
  }

  Future<List<DailyRecord>> getRecordsInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _userRecordsRef(userId).get();
    if (!snapshot.exists) return [];
    final data = snapshot.value as Map<dynamic, dynamic>;
    final records = <DailyRecord>[];
    for (final entry in data.entries) {
      final record = DailyRecord.fromMap(
        Map<String, dynamic>.from(entry.value as Map),
      );
      if (!record.date.isBefore(start) && !record.date.isAfter(end)) {
        records.add(record);
      }
    }
    records.sort((a, b) => a.date.compareTo(b.date));
    return records;
  }
}
