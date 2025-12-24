import 'package:flutter/material.dart';

import 'package:anchiano_client/l10n/app_localizations.dart';
import 'package:anchiano_client/data/api_client.dart';
import 'package:anchiano_client/data/task_repository.dart';
import 'package:anchiano_client/data/workspace_member_repository.dart';
import 'package:anchiano_client/data/realtime/realtime_service.dart';
import 'package:anchiano_client/ui/widgets/app_scaffold.dart';
import 'package:anchiano_client/utils/task_localization.dart';

import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';

class TaskDetailPage extends StatefulWidget {
  final int workspaceId;
  final String workspaceRole;
  final TaskItem task;
  final void Function(Locale locale) onChangeLanguage;
  final RealtimeService realtimeService;

  const TaskDetailPage({
    super.key,
    required this.workspaceId,
    required this.workspaceRole,
    required this.task,
    required this.onChangeLanguage,
    required this.realtimeService,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TaskRepository _taskRepository;
  late WorkspaceMemberRepository _memberRepository;
  late TaskItem _task;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  int? _selectedAssigneeId;
  DateTime? _dueDate;

  List<WorkspaceMemberItem> _members = [];
  bool _loadingMembers = true;

  List<TaskAuditEntry> _auditEntries = [];
  bool _loadingAudit = true;

  List<TaskAttachmentItem> _attachments = [];
  bool _loadingAttachments = true;
  bool _uploadingAttachment = false;

  // COMMENTS
  List<TaskCommentItem> _comments = [];
  bool _loadingComments = true;
  bool _postingComment = false;
  late TextEditingController _commentController;

  void Function()? _unsubAudit;
  void Function()? _unsubTasks;
  void Function()? _unsubComments;

  void Function()? _unsubPresence;
  List<Map<String, dynamic>> _presenceViewers = [];

  bool _deleting = false;

  bool get canEdit {
    final r = widget.workspaceRole.toUpperCase();
    return r == 'OWNER' || r == 'MEMBER';
  }

  bool _downloadingAttachment = false;

  Future<void> _downloadAndOpenAttachment(TaskAttachmentItem a) async {
    if (_downloadingAttachment) return;
    setState(() => _downloadingAttachment = true);

    try {
      final file = await _taskRepository.downloadAttachmentToTemp(
        widget.workspaceId,
        _task.id,
        a,
      );
      await OpenFilex.open(file.path);
    } catch (e) {
      if (!mounted) return;
      _showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _downloadingAttachment = false);
    }
  }

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    _taskRepository = TaskRepository(apiClient);
    _memberRepository = WorkspaceMemberRepository(apiClient);

    _task = widget.task;
    _titleController = TextEditingController(text: _task.title);
    _descriptionController = TextEditingController(text: _task.description ?? '');
    _selectedAssigneeId = _task.assigneeId;
    _dueDate = _task.dueDate;

    _commentController = TextEditingController();

    _loadMembers();
    _loadAuditLog();
    _loadAttachments();
    _loadComments();

    _unsubAudit = widget.realtimeService.subscribeAudit(
      widget.workspaceId,
      onEvent: (payload) {
        final raw = payload['taskId'];
        final taskId = raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '');
        if (taskId == null) return;
        if (taskId == _task.id) _loadAuditLog();
      },
    );

    _unsubTasks = widget.realtimeService.subscribeTasks(
      widget.workspaceId,
      onEvent: (payload) {
        final raw = payload['taskId'];
        final taskId = raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '');
        if (taskId == null) return;
        if (taskId == _task.id) {
          _reloadTaskFromList();
          _loadAttachments();
        }
      },
    );

    // COMMENTS realtime
    _unsubComments = widget.realtimeService.subscribeComments(
      widget.workspaceId,
      onEvent: (payload) {
        final raw = payload['taskId'];
        final taskId = raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '');
        if (taskId == null) return;
        if (taskId == _task.id) {
          _loadComments();
          // jouw backend logt comment ook naar audit, dus audit kan mee:
          _loadAuditLog();
        }
      },
    );

    _unsubPresence = widget.realtimeService.subscribeTaskPresence(
      widget.workspaceId,
      _task.id,
      onEvent: (list) {
        final viewers = <Map<String, dynamic>>[];
        for (final v in list) {
          if (v is Map) {
            viewers.add(v.map((k, val) => MapEntry(k.toString(), val)));
          }
        }
        if (!mounted) return;
        setState(() => _presenceViewers = viewers);
      },
    );

    widget.realtimeService.sendPresenceEnter(
      workspaceId: widget.workspaceId,
      taskId: _task.id,
    );
  }

  @override
  void dispose() {
    widget.realtimeService.sendPresenceLeave(
      workspaceId: widget.workspaceId,
      taskId: _task.id,
    );

    _unsubPresence?.call();
    _unsubPresence = null;

    _unsubAudit?.call();
    _unsubTasks?.call();
    _unsubComments?.call();

    _titleController.dispose();
    _descriptionController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _reloadTaskFromList() async {
    try {
      final list = await _taskRepository.getTasks(widget.workspaceId);
      final exists = list.any((t) => t.id == _task.id);

      if (!mounted) return;

      if (!exists) {
        Navigator.pop(context, true);
        return;
      }

      final updated = list.firstWhere((t) => t.id == _task.id);
      setState(() {
        _task = updated;
        _syncFromTask();
      });
    } catch (_) {}
  }

  Future<void> _loadMembers() async {
    try {
      final members = await _memberRepository.getMembers(widget.workspaceId);
      if (!mounted) return;
      setState(() {
        _members = members;
        _loadingMembers = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingMembers = false);
      _showError(context, e.toString());
    }
  }

  Future<void> _loadAuditLog() async {
    setState(() => _loadingAudit = true);
    try {
      final entries = await _taskRepository.getAuditLog(widget.workspaceId, _task.id);
      if (!mounted) return;
      setState(() {
        _auditEntries = entries;
        _loadingAudit = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingAudit = false);
      _showError(context, e.toString());
    }
  }

  Future<void> _onChangeStatus(BuildContext context, String newStatus) async {
    try {
      final updated = await _taskRepository.updateStatus(widget.workspaceId, _task.id, newStatus);
      if (!mounted) return;
      setState(() {
        _task = updated;
        _syncFromTask();
      });
      await _loadAuditLog();
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _onChangePriority(BuildContext context, String newPriority) async {
    try {
      final updated =
          await _taskRepository.updatePriority(widget.workspaceId, _task.id, newPriority);
      if (!mounted) return;
      setState(() {
        _task = updated;
        _syncFromTask();
      });
      await _loadAuditLog();
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  void _syncFromTask() {
    _titleController.text = _task.title;
    _descriptionController.text = _task.description ?? '';
    _selectedAssigneeId = _task.assigneeId;
    _dueDate = _task.dueDate;
  }

  Future<void> _pickDueDateTime(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _dueDate ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) {
      setState(() => _dueDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day));
      return;
    }

    setState(() {
      _dueDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _onSaveFields(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    if (!canEdit) return;

    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();

    if (title.isEmpty) {
      _showError(context, t.formErrorMissingFields);
      return;
    }

    try {
      final updated = await _taskRepository.updateFields(
        widget.workspaceId,
        _task.id,
        title: title,
        description: desc,
        assigneeId: _selectedAssigneeId,
        dueDate: _dueDate,
      );

      if (!mounted) return;
      setState(() {
        _task = updated;
        _syncFromTask();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.taskSaveButton)));
      await _loadAuditLog();
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _onDeleteTask(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    if (!canEdit || _deleting) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.taskDeleteTitle),
        content: Text(t.taskDeleteMessage(_task.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancelButton)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.taskDeleteConfirmButton),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _deleting = true);
    try {
      await _taskRepository.deleteTask(widget.workspaceId, _task.id);

      if (!mounted) return;

      widget.realtimeService.sendPresenceLeave(workspaceId: widget.workspaceId, taskId: _task.id);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      _showError(context, e.toString());
    }
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '-';
    final d = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  String _localizedAuditField(AppLocalizations t, String fieldName) {
    switch (fieldName) {
      case 'title':
        return t.taskFieldTitleLabel;
      case 'description':
        return t.taskFieldDescriptionLabel;
      case 'status':
        return t.taskFieldStatusLabel;
      case 'priority':
        return t.taskFieldPriorityLabel;
      case 'assigneeId':
        return t.taskFieldAssigneeLabel;
      case 'dueDate':
        return t.taskFieldDueDateLabel;
      case 'attachment':
        return t.taskAttachmentsTitle;
      case 'comment':
        // voeg eventueel later een echte vertaling toe in l10n
        return 'Comments';
      default:
        return fieldName;
    }
  }

  String _localizedAuditValue(AppLocalizations t, String field, String? value) {
    if (value == null || value.isEmpty) return '-';
    switch (field) {
      case 'status':
        return localizedAuditStatus(t, value);
      case 'priority':
        return localizedAuditPriority(t, value);
      default:
        return value;
    }
  }

  Widget _buildPresence() {
    if (_presenceViewers.isEmpty) return const SizedBox.shrink();

    String nameOf(Map<String, dynamic> v) {
      final dn = (v['displayName'] ?? '').toString().trim();
      if (dn.isNotEmpty) return dn;
      return (v['email'] ?? '').toString();
    }

    String initials(String s) {
      final parts = s.trim().split(RegExp(r'\s+'));
      if (parts.isEmpty) return '?';
      if (parts.length == 1) {
        return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
      }
      final a = parts[0].isNotEmpty ? parts[0][0] : '';
      final b = parts[1].isNotEmpty ? parts[1][0] : '';
      final res = '$a$b'.trim();
      return res.isEmpty ? '?' : res.toUpperCase();
    }

    final names = _presenceViewers.map(nameOf).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.visibility, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _presenceViewers.map((v) {
                    final n = nameOf(v);
                    return CircleAvatar(
                      radius: 14,
                      child: Text(initials(n), style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(names.join(', '), style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Future<void> _loadAttachments() async {
    setState(() => _loadingAttachments = true);
    try {
      final list = await _taskRepository.getAttachments(widget.workspaceId, _task.id);
      if (!mounted) return;
      setState(() {
        _attachments = list;
        _loadingAttachments = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingAttachments = false);
      _showError(context, e.toString());
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024.0;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024.0;
    return '${mb.toStringAsFixed(1)} MB';
  }

  Future<void> _pickAndUploadAttachment() async {
    final t = AppLocalizations.of(context)!;
    if (!canEdit || _uploadingAttachment) return;

    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.isEmpty) return;

    final f = result.files.first;
    final path = f.path;
    if (path == null) {
      _showError(context, t.taskAttachmentPickError);
      return;
    }

    setState(() => _uploadingAttachment = true);
    try {
      await _taskRepository.uploadAttachment(
        widget.workspaceId,
        _task.id,
        filePath: path,
        fileName: f.name,
      );

      if (!mounted) return;
      await _loadAttachments();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.taskAttachmentUploadSuccess)));
    } catch (e) {
      if (!mounted) return;
      _showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _uploadingAttachment = false);
    }
  }

  Future<void> _confirmAndDeleteAttachment(TaskAttachmentItem a) async {
    final t = AppLocalizations.of(context)!;
    if (!canEdit) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.taskAttachmentDeleteTitle),
        content: Text(t.taskAttachmentDeleteMessage(a.fileName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancelButton)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.taskAttachmentDeleteConfirmButton),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _taskRepository.deleteAttachment(widget.workspaceId, _task.id, a.id);
      if (!mounted) return;
      await _loadAttachments();
    } catch (e) {
      if (!mounted) return;
      _showError(context, e.toString());
    }
  }

  // COMMENTS
  Future<void> _loadComments() async {
    setState(() => _loadingComments = true);
    try {
      final list = await _taskRepository.getComments(widget.workspaceId, _task.id);
      if (!mounted) return;
      setState(() {
        _comments = list;
        _loadingComments = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingComments = false);
      _showError(context, e.toString());
    }
  }

  Future<void> _postComment() async {
    if (_postingComment) return;
    final body = _commentController.text.trim();
    if (body.isEmpty) return;

    setState(() => _postingComment = true);
    try {
      await _taskRepository.addComment(widget.workspaceId, _task.id, body: body);
      if (!mounted) return;
      _commentController.clear();
      await _loadComments();
      await _loadAuditLog();
    } catch (e) {
      if (!mounted) return;
      _showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _postingComment = false);
    }
  }

  Future<void> _confirmAndDeleteComment(TaskCommentItem c) async {
    if (!canEdit) return;
    final t = AppLocalizations.of(context)!;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete comment'),
        content: Text('Delete this comment?\n\n"${c.body}"'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancelButton)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _taskRepository.deleteComment(widget.workspaceId, _task.id, c.id);
      if (!mounted) return;
      await _loadComments();
      await _loadAuditLog();
    } catch (e) {
      if (!mounted) return;
      _showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AppScaffold(
      title: t.taskDetailTitle,
      showLogout: true,
      onChangeLanguage: widget.onChangeLanguage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPresence(),

            _buildTextField(t.taskFieldTitleLabel, _titleController, canEdit),
            const SizedBox(height: 16),
            _buildTextField(
              t.taskFieldDescriptionLabel,
              _descriptionController,
              canEdit,
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            Text(t.taskFieldAssigneeLabel, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            _loadingMembers
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<int>(
                    value: _selectedAssigneeId,
                    items: [
                      const DropdownMenuItem<int>(value: null, child: Text('-')),
                      ..._members.map(
                        (m) => DropdownMenuItem<int>(
                          value: m.userId,
                          child: Text(m.displayName),
                        ),
                      ),
                    ],
                    onChanged: canEdit ? (v) => setState(() => _selectedAssigneeId = v) : null,
                  ),

            const SizedBox(height: 16),

            Text(t.taskFieldDueDateLabel, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(_formatDateTime(_dueDate)),
                  ),
                ),
                if (canEdit)
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pickDueDateTime(context),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            _buildStatusDropdown(t),
            const SizedBox(height: 16),
            _buildPriorityDropdown(t),

            const SizedBox(height: 24),

            if (canEdit)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _deleting ? null : () => _onSaveFields(context),
                      child: Text(t.taskSaveButton),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _deleting ? null : () => _onDeleteTask(context),
                    child: Text(t.taskDeleteButton),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // COMMENTS SECTION
            Text('Comments', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Write a comment…',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _postingComment ? null : _postComment,
                  child: _postingComment
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (_loadingComments)
              const LinearProgressIndicator()
            else if (_comments.isEmpty)
              const Text('No comments yet.')
            else
              Column(
                children: _comments.map((c) {
                  final when = _formatDateTime(c.createdAt);
                  final who = (c.authorEmail ?? '-');
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.comment),
                    title: Text(c.body),
                    subtitle: Text('$when · $who'),
                    trailing: canEdit
                        ? IconButton(
                            tooltip: 'Delete',
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmAndDeleteComment(c),
                          )
                        : null,
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // ATTACHMENTS SECTION
            Text(t.taskAttachmentsTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            Row(
              children: [
                if (canEdit)
                  ElevatedButton.icon(
                    onPressed: _uploadingAttachment ? null : _pickAndUploadAttachment,
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      _uploadingAttachment ? t.taskAttachmentUploading : t.taskAttachmentUploadButton,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            if (_loadingAttachments)
              const LinearProgressIndicator()
            else if (_attachments.isEmpty)
              Text(t.taskAttachmentsEmpty)
            else
              Column(
                children: _attachments.map((a) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(a.fileName),
                    subtitle: Text('${_formatBytes(a.size)} · ${a.uploadedBy ?? '-'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: t.taskAttachmentOpenButton,
                          icon: const Icon(Icons.open_in_new),
                          onPressed: _downloadingAttachment ? null : () => _downloadAndOpenAttachment(a),
                        ),
                        if (canEdit)
                          IconButton(
                            tooltip: t.taskAttachmentDeleteConfirmButton,
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmAndDeleteAttachment(a),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // AUDIT LOG
            Text(t.taskAuditLogTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_loadingAudit)
              const LinearProgressIndicator()
            else if (_auditEntries.isEmpty)
              Text(t.taskAuditLogEmpty)
            else
              Column(
                children: _auditEntries.map((e) {
                  final ts = _formatDateTime(e.timestamp);
                  final field = _localizedAuditField(t, e.fieldName);
                  final oldVal = _localizedAuditValue(t, e.fieldName, e.oldValue);
                  final newVal = _localizedAuditValue(t, e.fieldName, e.newValue);

                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('$ts · $field: $oldVal → $newVal'),
                    subtitle: e.actor != null && e.actor!.isNotEmpty ? Text(t.taskAuditBy(e.actor!)) : null,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool enabled, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.taskFieldStatusLabel, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _task.status,
          items: [
            DropdownMenuItem(value: 'OPEN', child: Text(t.taskStatusOpen)),
            DropdownMenuItem(value: 'IN_PROGRESS', child: Text(t.taskStatusInProgress)),
            DropdownMenuItem(value: 'DONE', child: Text(t.taskStatusDone)),
          ],
          onChanged: canEdit ? (value) { if (value != null) _onChangeStatus(context, value); } : null,
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown(AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.taskFieldPriorityLabel, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _task.priority,
          items: [
            DropdownMenuItem(value: 'LOW', child: Text(t.taskPriorityLow)),
            DropdownMenuItem(value: 'MEDIUM', child: Text(t.taskPriorityMedium)),
            DropdownMenuItem(value: 'HIGH', child: Text(t.taskPriorityHigh)),
          ],
          onChanged: canEdit ? (value) { if (value != null) _onChangePriority(context, value); } : null,
        ),
      ],
    );
  }
}
