import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/workspace_repository.dart';
import 'workspace_event.dart';
import 'workspace_state.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final WorkspaceRepository workspaceRepository;

  WorkspaceBloc(this.workspaceRepository) : super(WorkspaceLoading()) {
    on<WorkspaceLoadRequested>(_onLoadRequested);
    on<WorkspaceCreateRequested>(_onCreateRequested);
    on<WorkspaceRenameRequested>(_onRenameRequested);
    on<WorkspaceDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
      WorkspaceLoadRequested event, Emitter<WorkspaceState> emit) async {
    emit(WorkspaceLoading());
    try {
      final workspaces = await workspaceRepository.getMyWorkspaces();
      emit(WorkspaceLoaded(workspaces));
    } catch (_) {
      emit(WorkspaceError('workspaceErrorLoad'));
    }
  }

  Future<void> _onCreateRequested(
      WorkspaceCreateRequested event, Emitter<WorkspaceState> emit) async {
    try {
      await workspaceRepository.createWorkspace(event.name);
      final workspaces = await workspaceRepository.getMyWorkspaces();
      emit(WorkspaceLoaded(workspaces));
    } catch (_) {
      emit(WorkspaceError('workspaceErrorCreate'));
    }
  }

  Future<void> _onRenameRequested(
      WorkspaceRenameRequested event, Emitter<WorkspaceState> emit) async {
    try {
      await workspaceRepository.renameWorkspace(
        workspaceId: event.workspaceId,
        name: event.name,
      );
      final workspaces = await workspaceRepository.getMyWorkspaces();
      emit(WorkspaceLoaded(workspaces));
    } catch (_) {
      emit(WorkspaceError('workspaceErrorRename'));
    }
  }

  Future<void> _onDeleteRequested(
      WorkspaceDeleteRequested event, Emitter<WorkspaceState> emit) async {
    try {
      await workspaceRepository.deleteWorkspace(event.workspaceId);
      final workspaces = await workspaceRepository.getMyWorkspaces();
      emit(WorkspaceLoaded(workspaces));
    } catch (_) {
      emit(WorkspaceError('workspaceErrorDelete'));
    }
  }
}
