import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:anchiano_client/l10n/app_localizations.dart';
import 'package:anchiano_client/data/realtime/realtime_service.dart';

import 'task_list_page.dart';
import 'workspace_members_page.dart';

import '../bloc/workspace/workspace_bloc.dart';
import '../bloc/workspace/workspace_event.dart';
import '../bloc/workspace/workspace_state.dart';
import 'widgets/app_scaffold.dart';

class WorkspaceListPage extends StatefulWidget {
  final void Function(Locale locale) onChangeLanguage;
  final RealtimeService realtimeService;

  const WorkspaceListPage({
    super.key,
    required this.onChangeLanguage,
    required this.realtimeService,
  });

  @override
  State<WorkspaceListPage> createState() => _WorkspaceListPageState();
}

class _WorkspaceListPageState extends State<WorkspaceListPage> {
  void Function()? _unsubWorkspaces;

  @override
  void initState() {
    super.initState();

    context.read<WorkspaceBloc>().add(WorkspaceLoadRequested());

    _unsubWorkspaces = widget.realtimeService
        .subscribeMyWorkspacesWhenConnected(
          onEvent: (_) {
            if (!mounted) return;
            context.read<WorkspaceBloc>().add(WorkspaceLoadRequested());
          },
        );
  }

  @override
  void dispose() {
    _unsubWorkspaces?.call();
    _unsubWorkspaces = null;
    super.dispose();
  }

  void _reloadWorkspaces() {
    context.read<WorkspaceBloc>().add(WorkspaceLoadRequested());
  }

  String _localizedWorkspaceError(AppLocalizations t, String key) {
    switch (key) {
      case 'workspaceErrorLoad':
        return t.workspaceErrorLoad;
      case 'workspaceErrorCreate':
        return t.workspaceErrorCreate;
      case 'workspaceErrorRename':
        return t.workspaceErrorRename;
      case 'workspaceErrorDelete':
        return t.workspaceErrorDelete;
      default:
        return key;
    }
  }

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

  Future<void> _createWorkspaceDialog() async {
    final t = AppLocalizations.of(context)!;
    final nameController = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.newWorkspaceTitle),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: t.newWorkspaceNameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancelButton),
          ),
          ElevatedButton(
            onPressed: () {
              final value = nameController.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: Text(t.newWorkspaceCreateButton),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty && mounted) {
      context.read<WorkspaceBloc>().add(WorkspaceCreateRequested(name));
    }
  }

  Future<void> _renameWorkspaceDialog(
    int workspaceId,
    String currentName,
  ) async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.workspaceRenameTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: t.workspaceRenameNameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancelButton),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: Text(t.workspaceRenameButton),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && mounted) {
      context.read<WorkspaceBloc>().add(
        WorkspaceRenameRequested(workspaceId: workspaceId, name: newName),
      );
    }
  }

  Future<bool> _confirmDeleteWorkspace(String name) async {
    final t = AppLocalizations.of(context)!;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.workspaceDeleteTitle),
        content: Text(t.workspaceDeleteMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelButton),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.workspaceDeleteConfirmButton),
          ),
        ],
      ),
    );

    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AppScaffold(
      title: t.workspaceListTitle,
      showLogout: true,
      onChangeLanguage: widget.onChangeLanguage,
      actions: [
        IconButton(
          tooltip: t.workspaceReloadButton,
          icon: const Icon(Icons.refresh),
          onPressed: _reloadWorkspaces,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _createWorkspaceDialog,
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<WorkspaceBloc, WorkspaceState>(
        builder: (context, state) {
          if (state is WorkspaceLoading || state is WorkspaceInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WorkspaceError) {
            return Center(
              child: Text(_localizedWorkspaceError(t, state.message)),
            );
          }

          if (state is WorkspaceLoaded) {
            if (state.workspaces.isEmpty) {
              return Center(child: Text(t.workspaceEmpty));
            }

            return ListView.builder(
              itemCount: state.workspaces.length,
              itemBuilder: (_, index) {
                final ws = state.workspaces[index];
                final roleText = _localizedRole(t, ws.role);
                final isOwner = ws.role.toUpperCase() == 'OWNER';

                return ListTile(
                  title: Text(ws.name),
                  subtitle: Text(t.workspaceRoleLabel(roleText)),
                  trailing: isOwner
                      ? PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'members') {
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WorkspaceMembersPage(
                                    workspaceId: ws.id,
                                    workspaceName: ws.name,
                                    workspaceRole: ws.role,
                                    onChangeLanguage: widget.onChangeLanguage,
                                    realtimeService: widget.realtimeService,
                                  ),
                                ),
                              );
                            } else if (value == 'rename') {
                              await _renameWorkspaceDialog(ws.id, ws.name);
                            } else if (value == 'delete') {
                              final ok = await _confirmDeleteWorkspace(ws.name);
                              if (!ok || !mounted) return;
                              context.read<WorkspaceBloc>().add(
                                WorkspaceDeleteRequested(workspaceId: ws.id),
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'members',
                              child: Text(t.workspaceMenuMembers),
                            ),
                            PopupMenuItem(
                              value: 'rename',
                              child: Text(t.workspaceMenuRename),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(t.workspaceMenuDelete),
                            ),
                          ],
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskListPage(
                          workspaceId: ws.id,
                          workspaceName: ws.name,
                          workspaceRole: ws.role,
                          onChangeLanguage: widget.onChangeLanguage,
                          realtimeService: widget.realtimeService,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          return Center(child: Text(t.noData));
        },
      ),
    );
  }
}
