import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums/task_priority.dart';
import '../../../../core/models/task_model.dart';
import '../../data/task_repository.dart';
import '../../domain/task_state.dart';

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;
  final String _userId;
  final Map<String, bool> _completedTasks = {};

  TaskNotifier(this._repository, this._userId) : super(const TaskState()) {
    _loadTasks();
  }

  void _loadTasks() {
    try {
      _repository
          .watchTasks(_userId)
          .listen(
            (tasks) {
              state = state.copyWith(tasks: tasks, isLoading: false);
            },
            onError: (_) {
              state = state.copyWith(isLoading: false);
            },
          );
    } catch (_) {
      // Firebase unavailable — show empty state instead of crashing.
      state = state.copyWith(isLoading: false);
    }
  }

  bool isTaskCompleted(String taskId) {
    return _completedTasks[taskId] ?? false;
  }

  void toggleTaskCompletion(String taskId) {
    _completedTasks[taskId] = !(_completedTasks[taskId] ?? false);
    state = state.copyWith();
  }

  Future<void> addTask({
    required String title,
    required String description,
    required TaskPriority priority,
    String? hadithRef,
    String? quranRef,
  }) async {
    final task = TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      priority: priority,
      isMandatory: false,
      hadithRef: hadithRef,
      quranRef: quranRef,
      createdAt: DateTime.now(),
    );

    await _repository.addTask(_userId, task);
  }

  Future<void> updateTask(TaskModel task) async {
    await _repository.updateTask(_userId, task);
  }

  Future<void> deleteTask(String taskId) async {
    await _repository.deleteTask(_userId, taskId);
  }

  Future<void> seedMandatoryTasks() async {
    await _repository.seedMandatoryTasks(_userId);
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final taskProvider =
    StateNotifierProvider.family<TaskNotifier, TaskState, String>((
      ref,
      userId,
    ) {
      final repository = ref.watch(taskRepositoryProvider);
      return TaskNotifier(repository, userId);
    });
