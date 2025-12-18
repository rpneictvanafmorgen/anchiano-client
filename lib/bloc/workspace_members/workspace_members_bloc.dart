import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/workspace_member_repository.dart';
import 'workspace_members_event.dart';
import 'workspace_members_state.dart';

class WorkspaceMembersBloc
    extends Bloc<WorkspaceMembersEvent, WorkspaceMembersState> {
  final WorkspaceMemberRepository repo;

  WorkspaceMembersBloc(this.repo) : super(WorkspaceMembersInitial()) {
    on<WorkspaceMembersLoadRequested>(_onLoad);
    on<WorkspaceMemberAddRequested>(_onAdd);
    on<WorkspaceMemberRoleUpdateRequested>(_onUpdateRole);
    on<WorkspaceMemberRemoveRequested>(_onRemove);
  }

  Future<void> _onLoad(WorkspaceMembersLoadRequested event,
      Emitter<WorkspaceMembersState> emit) async {
    emit(WorkspaceMembersLoading());
    try {
      final members = await repo.getMembers(event.workspaceId);
      emit(WorkspaceMembersLoaded(members));
    } catch (_) {
      emit(WorkspaceMembersError('workspaceMembersErrorLoad'));
    }
  }

  Future<void> _onAdd(WorkspaceMemberAddRequested event,
      Emitter<WorkspaceMembersState> emit) async {
    try {
      await repo.addMember(
        workspaceId: event.workspaceId,
        email: event.email,
        role: event.role,
      );
      final members = await repo.getMembers(event.workspaceId);
      emit(WorkspaceMembersLoaded(members));
    } catch (_) {
      emit(WorkspaceMembersError('workspaceMembersErrorAdd'));
    }
  }

  Future<void> _onUpdateRole(WorkspaceMemberRoleUpdateRequested event,
      Emitter<WorkspaceMembersState> emit) async {
    try {
      await repo.updateMemberRole(
        workspaceId: event.workspaceId,
        memberId: event.memberId,
        role: event.role,
      );
      final members = await repo.getMembers(event.workspaceId);
      emit(WorkspaceMembersLoaded(members));
    } catch (_) {
      emit(WorkspaceMembersError('workspaceMembersErrorUpdateRole'));
    }
  }

  Future<void> _onRemove(WorkspaceMemberRemoveRequested event,
      Emitter<WorkspaceMembersState> emit) async {
    try {
      await repo.removeMember(
        workspaceId: event.workspaceId,
        memberId: event.memberId,
      );
      final members = await repo.getMembers(event.workspaceId);
      emit(WorkspaceMembersLoaded(members));
    } catch (_) {
      emit(WorkspaceMembersError('workspaceMembersErrorRemove'));
    }
  }
}
