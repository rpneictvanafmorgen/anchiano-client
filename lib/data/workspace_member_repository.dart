import 'api_client.dart';

class WorkspaceMemberItem {
  final int id;
  final int userId;
  final String userEmail;
  final String userDisplayName;
  final String role;

  WorkspaceMemberItem({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userDisplayName,
    required this.role,
  });

  factory WorkspaceMemberItem.fromJson(Map<String, dynamic> json) {
    return WorkspaceMemberItem(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      userEmail: (json['userEmail'] as String?) ?? '',
      userDisplayName: (json['userDisplayName'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'VIEWER',
    );
  }

  String get displayName {
    if (userDisplayName.isNotEmpty) return userDisplayName;
    return userEmail;
  }
}

class WorkspaceMemberRepository {
  final ApiClient _apiClient;

  WorkspaceMemberRepository(this._apiClient);

  Future<List<WorkspaceMemberItem>> getMembers(int workspaceId) async {
    final response =
        await _apiClient.dio.get('/api/workspaces/$workspaceId/members');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => WorkspaceMemberItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WorkspaceMemberItem> addMember({
    required int workspaceId,
    required String email,
    required String role,
  }) async {
    final response = await _apiClient.dio.post(
      '/api/workspaces/$workspaceId/members',
      data: {
        'email': email,
        'role': role,
      },
    );
    return WorkspaceMemberItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WorkspaceMemberItem> updateMemberRole({
    required int workspaceId,
    required int memberId,
    required String role,
  }) async {
    final response = await _apiClient.dio.patch(
      '/api/workspaces/$workspaceId/members/$memberId',
      data: {'role': role},
    );
    return WorkspaceMemberItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> removeMember({
    required int workspaceId,
    required int memberId,
  }) async {
    await _apiClient.dio.delete(
      '/api/workspaces/$workspaceId/members/$memberId',
    );
  }
}
