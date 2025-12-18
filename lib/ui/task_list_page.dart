import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:anchiano_client/l10n/app_localizations.dart';
import 'package:anchiano_client/data/api_client.dart';
import 'package:anchiano_client/data/task_repository.dart';
import 'package:anchiano_client/data/realtime/realtime_service.dart';

import 'package:anchiano_client/bloc/task/task_bloc.dart';
import 'package:anchiano_client/bloc/task/task_event.dart';
import 'package:anchiano_client/bloc/task/task_state.dart';

import 'package:anchiano_client/ui/widgets/app_scaffold.dart';
import 'package:anchiano_client/utils/task_localization.dart';

import 'task_detail_page.dart';

class TaskListPage extends StatefulWidget {
  final int workspaceId;
  final String workspaceName;
  final String workspaceRole; // OWNER / MEMBER / VIEWER
  final void Function(Locale locale) onChangeLanguage;
  final RealtimeService realtimeService;

  const TaskListPage({
    super.key,
    required this.workspaceId,
    required this.workspaceName,
    required this.workspaceRole,
    required this.onChangeLanguage,
    required this.realtimeService,
  });

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  bool get canEdit {
    final r = widget.workspaceRole.toUpperCase();
    return r == 'OWNER' || r == 'MEMBER';
  }

  String _localizedTaskError(AppLocalizations t, String key) {
    switch (key) {
      case 'taskErrorLoad':
        return t.taskErrorLoad;
      case 'taskErrorCreate':
        return t.taskErrorCreate;
      case 'taskErrorDelete':
        return t.taskErrorDelete;
      default:
        return key;
    }
  }

  void _reloadTasks(BuildContext context) {
    context.read<TaskBloc>().add(TaskLoadRequested(widget.workspaceId));
  }

  Future<void> _showCreateTaskDialog(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    final title = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.newTaskTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: t.newTaskNameLabel),
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
            child: Text(t.newTaskCreateButton),
          ),
        ],
      ),
    );

    if (title != null && title.isNotEmpty && context.mounted) {
      context.read<TaskBloc>().add(
        TaskCreateRequested(workspaceId: widget.workspaceId, title: title),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final apiClient = ApiClient();
        final repo = TaskRepository(apiClient);
        final bloc = TaskBloc(repo, widget.realtimeService);
        bloc.add(TaskWorkspaceChanged(widget.workspaceId));
        return bloc;
      },
      child: Builder(
        builder: (innerContext) {
          final t = AppLocalizations.of(innerContext)!;

          return AppScaffold(
            title: '${t.taskListTitle} - ${widget.workspaceName}',
            onChangeLanguage: widget.onChangeLanguage,
            showLogout: true,
            actions: [
              IconButton(
                tooltip: t.taskReloadButton,
                icon: const Icon(Icons.refresh),
                onPressed: () => _reloadTasks(innerContext),
              ),
            ],
            floatingActionButton: canEdit
                ? FloatingActionButton(
                    onPressed: () => _showCreateTaskDialog(innerContext),
                    child: const Icon(Icons.add),
                  )
                : null,
            body: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskInitial || state is TaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TaskError) {
                  return Center(
                    child: Text(_localizedTaskError(t, state.message)),
                  );
                }

                if (state is TaskLoaded) {
                  if (state.tasks.isEmpty) {
                    return Center(child: Text(t.taskEmpty));
                  }

                  return ListView.builder(
                    itemCount: state.tasks.length,
                    itemBuilder: (_, index) {
                      final task = state.tasks[index];

                      final statusText = localizedStatus(t, task.status);
                      final priorityText = localizedPriority(t, task.priority);

                      return ListTile(
                        title: Text(task.title),
                        subtitle: Text('$statusText · $priorityText'),
                        onTap: () async {
                          final result = await Navigator.push(
                            innerContext,
                            MaterialPageRoute(
                              builder: (_) => TaskDetailPage(
                                workspaceId: widget.workspaceId,
                                workspaceRole: widget.workspaceRole,
                                task: task,
                                onChangeLanguage: widget.onChangeLanguage,
                                realtimeService: widget.realtimeService,
                              ),
                            ),
                          );

                          if (!innerContext.mounted) return;

                          if (result == true) {
                            innerContext.read<TaskBloc>().add(
                              TaskLoadRequested(widget.workspaceId),
                            );
                            return;
                          }

                          innerContext.read<TaskBloc>().add(
                            TaskLoadRequested(widget.workspaceId),
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
        },
      ),
    );
  }
}
