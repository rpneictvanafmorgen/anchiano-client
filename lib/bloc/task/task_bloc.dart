import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/task_repository.dart';
import '../../data/realtime/realtime_service.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;
  final RealtimeService realtimeService;

  void Function()? _unsubTasks;
  int? _currentWorkspaceId;

  TaskBloc(this.taskRepository, this.realtimeService) : super(TaskInitial()) {
    on<TaskWorkspaceChanged>(_onWorkspaceChanged);
    on<TaskLoadRequested>(_onLoadRequested);
    on<TaskCreateRequested>(_onCreateRequested);
    on<TaskRealtimeEventReceived>(_onRealtimeEventReceived);
  }

  Future<void> _onWorkspaceChanged(
      TaskWorkspaceChanged event, Emitter<TaskState> emit) async {
    _unsubTasks?.call();
    _unsubTasks = null;

    _currentWorkspaceId = event.workspaceId;

    _unsubTasks = realtimeService.subscribeTasks(
      event.workspaceId,
      onEvent: (payload) => add(TaskRealtimeEventReceived(payload)),
    );

    add(TaskLoadRequested(event.workspaceId));
  }

  Future<void> _onLoadRequested(
      TaskLoadRequested event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await taskRepository.getTasks(event.workspaceId);
      emit(TaskLoaded(tasks));
    } catch (_) {
      emit(TaskError('taskErrorLoad'));
    }
  }

  Future<void> _onCreateRequested(
      TaskCreateRequested event, Emitter<TaskState> emit) async {
    try {
      await taskRepository.createTask(event.workspaceId, event.title);
      final tasks = await taskRepository.getTasks(event.workspaceId);
      emit(TaskLoaded(tasks));
    } catch (_) {
      emit(TaskError('taskErrorCreate'));
    }
  }

  Future<void> _onRealtimeEventReceived(
      TaskRealtimeEventReceived event, Emitter<TaskState> emit) async {
    final wsId = _currentWorkspaceId;
    if (wsId == null) return;

    final type = (event.payload['type'] ?? '').toString();
    if (type != 'CREATED' && type != 'UPDATED' && type != 'DELETED') return;

    try {
      final tasks = await taskRepository.getTasks(wsId);
      emit(TaskLoaded(tasks));
    } catch (_) {
    }
  }

  @override
  Future<void> close() {
    _unsubTasks?.call();
    _unsubTasks = null;
    return super.close();
  }
}
