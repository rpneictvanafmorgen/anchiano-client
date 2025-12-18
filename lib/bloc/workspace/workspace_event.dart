abstract class WorkspaceEvent {}

class WorkspaceLoadRequested extends WorkspaceEvent {}

class WorkspaceCreateRequested extends WorkspaceEvent {
  final String name;
  WorkspaceCreateRequested(this.name);
}

class WorkspaceRenameRequested extends WorkspaceEvent {
  final int workspaceId;
  final String name;

  WorkspaceRenameRequested({
    required this.workspaceId,
    required this.name,
  });
}

class WorkspaceDeleteRequested extends WorkspaceEvent {
  final int workspaceId;

  WorkspaceDeleteRequested({required this.workspaceId});
}
