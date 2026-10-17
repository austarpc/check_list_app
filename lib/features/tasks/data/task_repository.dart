import 'package:firebase_database/firebase_database.dart';

import '../../../../core/models/task_model.dart';
import '../../../../core/enums/task_priority.dart';

class TaskRepository {
  final FirebaseDatabase? _databaseOverride;

  TaskRepository({FirebaseDatabase? database}) : _databaseOverride = database;

  FirebaseDatabase get _database {
    if (_databaseOverride != null) return _databaseOverride;
    return FirebaseDatabase.instance;
  }

  DatabaseReference _userTasksRef(String userId) {
    return _database.ref('users/$userId/tasks');
  }

  Stream<List<TaskModel>> watchTasks(String userId) {
    return _userTasksRef(userId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.values.map((e) {
        return TaskModel.fromMap(Map<String, dynamic>.from(e as Map));
      }).toList();
    });
  }

  Future<void> addTask(String userId, TaskModel task) async {
    await _userTasksRef(userId).child(task.id).set(task.toMap());
  }

  Future<void> updateTask(String userId, TaskModel task) async {
    await _userTasksRef(userId).child(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await _userTasksRef(userId).child(taskId).remove();
  }

  Future<bool> hasTasks(String userId) async {
    final snapshot = await _database.ref('users/$userId/tasks').get();
    return snapshot.exists && (snapshot.value as Map).isNotEmpty;
  }

  Future<void> seedMandatoryTasks(String userId) async {
    final tasks = [
      TaskModel(
        id: 'mandatory_fajr',
        title: 'ফজরের সালাত',
        description: 'ফজরের ফরজ সালাত আদায় করা',
        priority: TaskPriority.mandatory,
        isMandatory: true,
        createdAt: DateTime.now(),
        sortOrder: 1,
      ),
      TaskModel(
        id: 'mandatory_dhuhr',
        title: 'যোহরের সালাত',
        description: 'যোহরের ফরজ সালাত আদায় করা',
        priority: TaskPriority.mandatory,
        isMandatory: true,
        createdAt: DateTime.now(),
        sortOrder: 2,
      ),
      TaskModel(
        id: 'mandatory_asr',
        title: 'আসরের সালাত',
        description: 'আসরের ফরজ সালাত আদায় করা',
        priority: TaskPriority.mandatory,
        isMandatory: true,
        createdAt: DateTime.now(),
        sortOrder: 3,
      ),
      TaskModel(
        id: 'mandatory_maghrib',
        title: 'মাগরিবের সালাত',
        description: 'মাগরিবের ফরজ সালাত আদায় করা',
        priority: TaskPriority.mandatory,
        isMandatory: true,
        createdAt: DateTime.now(),
        sortOrder: 4,
      ),
      TaskModel(
        id: 'mandatory_isha',
        title: 'ইশার সালাত',
        description: 'ইশার ফরজ সালাত আদায় করা',
        priority: TaskPriority.mandatory,
        isMandatory: true,
        createdAt: DateTime.now(),
        sortOrder: 5,
      ),
      TaskModel(
        id: 'mandatory_quran',
        title: 'কুরআন তিলাওয়াত',
        description: 'প্রতিদিন কমপক্ষে ১ পৃষ্ঠা কুরআন পড়া',
        priority: TaskPriority.mandatory,
        isMandatory: true,
        createdAt: DateTime.now(),
        sortOrder: 6,
      ),
      TaskModel(
        id: 'mandatory_azkar',
        title: 'সকাল-সন্ধ্যার আযকার',
        description: "সকাল ও সন্ধ্যার যিকির ও দু'আ পড়া",
        priority: TaskPriority.mandatory,
        isMandatory: true,
        createdAt: DateTime.now(),
        sortOrder: 7,
      ),
    ];

    for (final task in tasks) {
      await _userTasksRef(userId).child(task.id).set(task.toMap());
    }
  }
}
