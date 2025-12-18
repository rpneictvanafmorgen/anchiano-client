import 'api_client.dart';

class WorkspaceSummary {
  final int id;
  final String name;
  final String role;

  WorkspaceSummary({
    required this.id,
    required this.name,
    required this.role,
  });

  factory WorkspaceSummary.fromJson(Map<String, dynamic> json) {
    return WorkspaceSummary(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      role: (json['currentUserRole'] as String?) ?? 'UNKNOWN',
    );
  }
}

class WorkspaceRepository {
  final ApiClient _apiClient;

  WorkspaceRepository(this._apiClient);

  Future<List<WorkspaceSummary>> getMyWorkspaces() async {
    final response = await _apiClient.dio.get('/api/workspaces');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => WorkspaceSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WorkspaceSummary> createWorkspace(String name) async {
    final response = await _apiClient.dio.post(
      '/api/workspaces',
      data: {'name': name},
    );

    return WorkspaceSummary.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WorkspaceSummary> renameWorkspace({
    required int workspaceId,
    required String name,
  }) async {
    final response = await _apiClient.dio.patch(
      '/api/workspaces/$workspaceId',
      data: {'name': name},
    );

    return WorkspaceSummary.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteWorkspace(int workspaceId) async {
    await _apiClient.dio.delete('/api/workspaces/$workspaceId');
  }
}
