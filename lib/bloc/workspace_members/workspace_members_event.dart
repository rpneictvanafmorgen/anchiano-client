abstract class WorkspaceMembersEvent {}

class WorkspaceMembersLoadRequested extends WorkspaceMembersEvent {
  final int workspaceId;
  WorkspaceMembersLoadRequested(this.workspaceId);
}

class WorkspaceMemberAddRequested extends WorkspaceMembersEvent {
  final int workspaceId;
  final String email;
  final String role;

  WorkspaceMemberAddRequested({
    required this.workspaceId,
    required this.email,
    required this.role,
  });
}

class WorkspaceMemberRoleUpdateRequested extends WorkspaceMembersEvent {
  final int workspaceId;
  final int memberId;
  final String role;

  WorkspaceMemberRoleUpdateRequested({
    required this.workspaceId,
    required this.memberId,
    required this.role,
  });
}

class WorkspaceMemberRemoveRequested extends WorkspaceMembersEvent {
  final int workspaceId;
  final int memberId;

  WorkspaceMemberRemoveRequested({
    required this.workspaceId,
    required this.memberId,
  });
}
