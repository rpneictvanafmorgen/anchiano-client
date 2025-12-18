import 'package:equatable/equatable.dart';
import '../../data/workspace_repository.dart';

abstract class WorkspaceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WorkspaceInitial extends WorkspaceState {}

class WorkspaceLoading extends WorkspaceState {}

class WorkspaceLoaded extends WorkspaceState {
  final List<WorkspaceSummary> workspaces;

  WorkspaceLoaded(this.workspaces);

  @override
  List<Object?> get props => [workspaces];
}

class WorkspaceError extends WorkspaceState {
  final String message;

  WorkspaceError(this.message);

  @override
  List<Object?> get props => [message];
}
