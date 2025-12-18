import '../../data/workspace_member_repository.dart';

abstract class WorkspaceMembersState {}

class WorkspaceMembersInitial extends WorkspaceMembersState {}

class WorkspaceMembersLoading extends WorkspaceMembersState {}

class WorkspaceMembersLoaded extends WorkspaceMembersState {
  final List<WorkspaceMemberItem> members;
  WorkspaceMembersLoaded(this.members);
}

class WorkspaceMembersError extends WorkspaceMembersState {
  final String message;
  WorkspaceMembersError(this.message);
}
