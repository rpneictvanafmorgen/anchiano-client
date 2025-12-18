abstract class TaskEvent {}

class TaskWorkspaceChanged extends TaskEvent {
  final int workspaceId;

  TaskWorkspaceChanged(this.workspaceId);
}

class TaskLoadRequested extends TaskEvent {
  final int workspaceId;

  TaskLoadRequested(this.workspaceId);
}

class TaskCreateRequested extends TaskEvent {
  final int workspaceId;
  final String title;

  TaskCreateRequested({
    required this.workspaceId,
    required this.title,
  });
}

class TaskRealtimeEventReceived extends TaskEvent {
  final Map<String, dynamic> payload;

  TaskRealtimeEventReceived(this.payload);
}
