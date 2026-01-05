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

enum _TaskSortField { title, status, priority }
enum _TaskSortDir { asc, desc }

class TaskListPage extends StatefulWidget {
  final int workspaceId;
  final String workspaceName;
  final String workspaceRole;
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

  final TextEditingController _searchController = TextEditingController();
  String? _statusFilter;
  String? _priorityFilter;
  _TaskSortField _sortField = _TaskSortField.title;
  _TaskSortDir _sortDir = _TaskSortDir.asc;

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TaskItem> _applySearchFilterSort(List<TaskItem> tasks) {
    final q = _searchController.text.trim().toLowerCase();

    bool matchesQuery(TaskItem task) {
      if (q.isEmpty) return true;
      final title = task.title.toLowerCase();
      final desc = (task.description ?? '').toLowerCase();
      return title.contains(q) || desc.contains(q);
    }

    bool matchesStatus(TaskItem task) {
      if (_statusFilter == null) return true;
      return task.status.toUpperCase() == _statusFilter;
    }

    bool matchesPriority(TaskItem task) {
      if (_priorityFilter == null) return true;
      return task.priority.toUpperCase() == _priorityFilter;
    }

    int cmp(String a, String b) => a.compareTo(b);

    int compare(TaskItem a, TaskItem b) {
      int result;
      switch (_sortField) {
        case _TaskSortField.title:
          result = cmp(a.title.toLowerCase(), b.title.toLowerCase());
          break;
        case _TaskSortField.status:
          result = cmp(a.status.toUpperCase(), b.status.toUpperCase());
          break;
        case _TaskSortField.priority:
          result = cmp(a.priority.toUpperCase(), b.priority.toUpperCase());
          break;
      }
      return _sortDir == _TaskSortDir.asc ? result : -result;
    }

    final filtered = tasks
        .where((t) => matchesQuery(t) && matchesStatus(t) && matchesPriority(t))
        .toList();

    filtered.sort(compare);
    return filtered;
  }

  Widget _buildSearchFilterSortBar(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: t.taskSearchHint,
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: t.taskClearSearch,
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _searchController.clear());
                      },
                    ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _statusFilter,
                  decoration: InputDecoration(
                    labelText: t.taskFilterStatusLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text(t.taskFilterAll)),
                    DropdownMenuItem(value: 'OPEN', child: Text(t.taskStatusOpen)),
                    DropdownMenuItem(
                      value: 'IN_PROGRESS',
                      child: Text(t.taskStatusInProgress),
                    ),
                    DropdownMenuItem(value: 'DONE', child: Text(t.taskStatusDone)),
                  ],
                  onChanged: (v) => setState(() => _statusFilter = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _priorityFilter,
                  decoration: InputDecoration(
                    labelText: t.taskFilterPriorityLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text(t.taskFilterAll)),
                    DropdownMenuItem(value: 'LOW', child: Text(t.taskPriorityLow)),
                    DropdownMenuItem(value: 'MEDIUM', child: Text(t.taskPriorityMedium)),
                    DropdownMenuItem(value: 'HIGH', child: Text(t.taskPriorityHigh)),
                  ],
                  onChanged: (v) => setState(() => _priorityFilter = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<_TaskSortField>(
                  value: _sortField,
                  decoration: InputDecoration(
                    labelText: t.taskSortLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: _TaskSortField.title,
                      child: Text(t.taskSortTitle),
                    ),
                    DropdownMenuItem(
                      value: _TaskSortField.status,
                      child: Text(t.taskSortStatus),
                    ),
                    DropdownMenuItem(
                      value: _TaskSortField.priority,
                      child: Text(t.taskSortPriority),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _sortField = v);
                  },
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: _sortDir == _TaskSortDir.asc
                    ? t.taskSortAsc
                    : t.taskSortDesc,
                icon: Icon(
                  _sortDir == _TaskSortDir.asc
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                ),
                onPressed: () {
                  setState(() {
                    _sortDir = _sortDir == _TaskSortDir.asc
                        ? _TaskSortDir.desc
                        : _TaskSortDir.asc;
                  });
                },
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _statusFilter = null;
                    _priorityFilter = null;
                    _sortField = _TaskSortField.title;
                    _sortDir = _TaskSortDir.asc;
                  });
                },
                child: Text(t.taskFiltersReset),
              ),
            ],
          ),
        ],
      ),
    );
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
            body: Column(
              children: [
                _buildSearchFilterSortBar(t),
                const Divider(height: 1),
                Expanded(
                  child: BlocBuilder<TaskBloc, TaskState>(
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

                        final visible = _applySearchFilterSort(state.tasks);

                        if (visible.isEmpty) {
                          return Center(child: Text(t.taskNoResults));
                        }

                        return ListView.builder(
                          itemCount: visible.length,
                          itemBuilder: (_, index) {
                            final task = visible[index];

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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
