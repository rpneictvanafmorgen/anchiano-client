import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';

class TaskItem {
  final int id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final int? assigneeId;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool completed;

  TaskItem({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.assigneeId,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
    required this.completed,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'OPEN',
      priority: json['priority'] as String? ?? 'MEDIUM',
      assigneeId: json['assigneeId'] as int?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

class TaskAuditEntry {
  final int id;
  final DateTime timestamp;
  final String fieldName;
  final String? oldValue;
  final String? newValue;
  final String? actor;
  final String? reason;

  TaskAuditEntry({
    required this.id,
    required this.timestamp,
    required this.fieldName,
    this.oldValue,
    this.newValue,
    this.actor,
    this.reason,
  });

  factory TaskAuditEntry.fromJson(Map<String, dynamic> json) {
    return TaskAuditEntry(
      id: json['id'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      fieldName: json['fieldName'] as String,
      oldValue: json['oldValue'] as String?,
      newValue: json['newValue'] as String?,
      actor: json['actor'] as String?,
      reason: json['reason'] as String?,
    );
  }
}

class TaskRepository {
  final ApiClient _apiClient;

  TaskRepository(this._apiClient);

  Future<List<TaskItem>> getTasks(int workspaceId) async {
    final response = await _apiClient.dio.get(
      '/api/workspaces/$workspaceId/tasks',
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaskItem> createTask(int workspaceId, String title) async {
    final response = await _apiClient.dio.post(
      '/api/workspaces/$workspaceId/tasks',
      data: {'title': title},
    );
    return TaskItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TaskItem> updateStatus(
    int workspaceId,
    int taskId,
    String status,
  ) async {
    try {
      final response = await _apiClient.dio.patch(
        '/api/workspaces/$workspaceId/tasks/$taskId/status',
        data: {'status': status},
      );
      return TaskItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('updateStatus error: ${e.response?.statusCode}');
      debugPrint('updateStatus data: ${e.response?.data}');
      rethrow;
    }
  }

  Future<TaskItem> updatePriority(
    int workspaceId,
    int taskId,
    String priority,
  ) async {
    try {
      final response = await _apiClient.dio.patch(
        '/api/workspaces/$workspaceId/tasks/$taskId/priority',
        data: {'priority': priority},
      );
      return TaskItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('updatePriority error: ${e.response?.statusCode}');
      debugPrint('updatePriority data: ${e.response?.data}');
      rethrow;
    }
  }

  Future<TaskItem> updateFields(
    int workspaceId,
    int taskId, {
    String? title,
    String? description,
    int? assigneeId,
    DateTime? dueDate,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (assigneeId != null) data['assigneeId'] = assigneeId;
    if (dueDate != null) data['dueDate'] = dueDate.toUtc().toIso8601String();

    final response = await _apiClient.dio.patch(
      '/api/workspaces/$workspaceId/tasks/$taskId',
      data: data,
    );

    return TaskItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<TaskAuditEntry>> getAuditLog(int workspaceId, int taskId) async {
    final response = await _apiClient.dio.get(
      '/api/workspaces/$workspaceId/tasks/$taskId/audit-log',
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => TaskAuditEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteTask(int workspaceId, int taskId) async {
    await _apiClient.dio.delete('/api/workspaces/$workspaceId/tasks/$taskId');
  }
}

class TaskAttachmentItem {
  final int id;
  final String fileName;
  final String contentType;
  final int size;
  final DateTime createdAt;
  final String? uploadedBy;

  TaskAttachmentItem({
    required this.id,
    required this.fileName,
    required this.contentType,
    required this.size,
    required this.createdAt,
    this.uploadedBy,
  });

  factory TaskAttachmentItem.fromJson(Map<String, dynamic> json) {
    return TaskAttachmentItem(
      id: json['id'] as int,
      fileName: json['fileName'] as String? ?? '',
      contentType: json['contentType'] as String? ?? 'application/octet-stream',
      size: (json['size'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      uploadedBy: json['uploadedBy'] as String?,
    );
  }
}

extension TaskAttachmentsApi on TaskRepository {
  Future<List<TaskAttachmentItem>> getAttachments(
    int workspaceId,
    int taskId,
  ) async {
    final res = await _apiClient.dio.get(
      '/api/workspaces/$workspaceId/tasks/$taskId/attachments',
    );
    final list = res.data as List<dynamic>;
    return list
        .map((e) => TaskAttachmentItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaskAttachmentItem> uploadAttachment(
    int workspaceId,
    int taskId, {
    required String filePath,
    required String fileName,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final res = await _apiClient.dio.post(
      '/api/workspaces/$workspaceId/tasks/$taskId/attachments',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    return TaskAttachmentItem.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteAttachment(
    int workspaceId,
    int taskId,
    int attachmentId,
  ) async {
    await _apiClient.dio.delete(
      '/api/workspaces/$workspaceId/tasks/$taskId/attachments/$attachmentId',
    );
  }
}
