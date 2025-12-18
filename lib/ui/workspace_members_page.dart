import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:anchiano_client/l10n/app_localizations.dart';
import 'package:anchiano_client/data/api_client.dart';
import 'package:anchiano_client/data/workspace_member_repository.dart';
import 'package:anchiano_client/data/realtime/realtime_service.dart';

import 'package:anchiano_client/ui/widgets/app_scaffold.dart';

import 'package:anchiano_client/bloc/workspace_members/workspace_members_bloc.dart';
import 'package:anchiano_client/bloc/workspace_members/workspace_members_event.dart';
import 'package:anchiano_client/bloc/workspace_members/workspace_members_state.dart';

class WorkspaceMembersPage extends StatefulWidget {
  final int workspaceId;
  final String workspaceName;
  final String workspaceRole;
  final void Function(Locale locale) onChangeLanguage;
  final RealtimeService realtimeService;

  const WorkspaceMembersPage({
    super.key,
    required this.workspaceId,
    required this.workspaceName,
    required this.workspaceRole,
    required this.onChangeLanguage,
    required this.realtimeService,
  });

  @override
  State<WorkspaceMembersPage> createState() => _WorkspaceMembersPageState();
}

class _WorkspaceMembersPageState extends State<WorkspaceMembersPage> {
  bool get isOwner => widget.workspaceRole.toUpperCase() == 'OWNER';

  void Function()? _unsubWorkspaceEvents;

  String _localizedRole(AppLocalizations t, String backendRole) {
    switch (backendRole.toUpperCase()) {
      case 'OWNER':
        return t.workspaceRoleOwner;
      case 'MEMBER':
        return t.workspaceRoleMember;
      case 'VIEWER':
        return t.workspaceRoleViewer;
      default:
        return backendRole;
    }
  }

  List<DropdownMenuItem<String>> _roleItems(AppLocalizations t) {
    return [
      DropdownMenuItem(value: 'OWNER', child: Text(t.workspaceRoleOwner)),
      DropdownMenuItem(value: 'MEMBER', child: Text(t.workspaceRoleMember)),
      DropdownMenuItem(value: 'VIEWER', child: Text(t.workspaceRoleViewer))
    ];
  }

  String _localizedMembersError(AppLocalizations t, String key) {
    switch (key) {
      case 'workspaceMembersErrorLoad':
        return t.workspaceMembersErrorLoad;
      case 'workspaceMembersErrorAdd':
        return t.workspaceMembersErrorAdd;
      case 'workspaceMembersErrorUpdateRole':
        return t.workspaceMembersErrorUpdateRole;
      case 'workspaceMembersErrorRemove':
        return t.workspaceMembersErrorRemove;
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();

    _unsubWorkspaceEvents = widget.realtimeService.subscribeMyWorkspaces(
      onEvent: (payload) {
        final wsIdRaw = payload['workspaceId'];
        final wsId = wsIdRaw is num ? wsIdRaw.toInt() : int.tryParse('$wsIdRaw');

        if (wsId == widget.workspaceId && mounted) {
          context
              .read<WorkspaceMembersBloc>()
              .add(WorkspaceMembersLoadRequested(widget.workspaceId));
        }
      },
    );
  }

  @override
  void dispose() {
    _unsubWorkspaceEvents?.call();
    _unsubWorkspaceEvents = null;
    super.dispose();
  }

  Future<void> _showAddMemberDialog(BuildContext context) async {
    final t = AppLocalizations.of(context)!;

    final emailController = TextEditingController();
    String selectedRole = 'MEMBER';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.workspaceMembersAddTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: t.workspaceMembersEmailLabel),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(labelText: t.workspaceMembersRoleLabel),
              items: _roleItems(t),
              onChanged: (v) {
                if (v != null) selectedRole = v;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelButton),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.workspaceMembersAddButton),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    final email = emailController.text.trim();
    if (email.isEmpty) return;

    context.read<WorkspaceMembersBloc>().add(
          WorkspaceMemberAddRequested(
            workspaceId: widget.workspaceId,
            email: email,
            role: selectedRole,
          ),
        );
  }

  Future<bool> _confirmRemoveMember(BuildContext context, String name) async {
    final t = AppLocalizations.of(context)!;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.workspaceMembersRemoveTitle),
        content: Text(t.workspaceMembersRemoveMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelButton),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.workspaceMembersRemoveConfirmButton),
          ),
        ],
      ),
    );

    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) {
        final apiClient = ApiClient();
        final repo = WorkspaceMemberRepository(apiClient);
        final bloc = WorkspaceMembersBloc(repo);
        bloc.add(WorkspaceMembersLoadRequested(widget.workspaceId));
        return bloc;
      },
      child: Builder(
        builder: (innerContext) {
          return AppScaffold(
            title: '${t.workspaceMembersTitle} - ${widget.workspaceName}',
            showLogout: true,
            onChangeLanguage: widget.onChangeLanguage,
            floatingActionButton: isOwner
                ? FloatingActionButton(
                    onPressed: () => _showAddMemberDialog(innerContext),
                    child: const Icon(Icons.person_add),
                  )
                : null,
            body: BlocBuilder<WorkspaceMembersBloc, WorkspaceMembersState>(
              builder: (context, state) {
                if (state is WorkspaceMembersInitial || state is WorkspaceMembersLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is WorkspaceMembersError) {
                  return Center(child: Text(_localizedMembersError(t, state.message)));
                }

                if (state is WorkspaceMembersLoaded) {
                  if (state.members.isEmpty) {
                    return Center(child: Text(t.workspaceMembersEmpty));
                  }

                  return ListView.separated(
                    itemCount: state.members.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final m = state.members[i];
                      final roleText = _localizedRole(t, m.role);

                      return ListTile(
                        title: Text(m.displayName),
                        subtitle: Text('${m.userEmail} · ${t.workspaceRoleLabel(roleText)}'),
                        trailing: isOwner
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DropdownButton<String>(
                                    value: m.role.toUpperCase(),
                                    items: _roleItems(t),
                                    onChanged: (v) {
                                      if (v == null) return;
                                      innerContext.read<WorkspaceMembersBloc>().add(
                                            WorkspaceMemberRoleUpdateRequested(
                                              workspaceId: widget.workspaceId,
                                              memberId: m.id,
                                              role: v,
                                            ),
                                          );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      final ok = await _confirmRemoveMember(innerContext, m.displayName);
                                      if (!ok || !innerContext.mounted) return;

                                      innerContext.read<WorkspaceMembersBloc>().add(
                                            WorkspaceMemberRemoveRequested(
                                              workspaceId: widget.workspaceId,
                                              memberId: m.id,
                                            ),
                                          );
                                    },
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
                  );
                }

                return Center(child: Text(t.noData));
              },
            ),
          );
        },
      ),
    );
  }
}
