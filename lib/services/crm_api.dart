import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

part 'api_exception.dart';
part 'auth_result.dart';
part 'auth_user.dart';
part 'client_summary.dart';
part 'dashboard_summary.dart';
part 'project_summary.dart';
part 'report_summary.dart';
part 'settings_summary.dart';

class CrmApi {
  CrmApi._();

  static final CrmApi instance = CrmApi._();

  static const _tokenKey = 'crm.accessToken';
  static const _refreshTokenKey = 'crm.refreshToken';
  static const _userKey = 'crm.user';
  static const _apiBaseUrl = String.fromEnvironment(
    'CRM_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api',
  );

  static const workflowStages = [
    'Lead Capture',
    'Lead Qualification',
    'Lead Assignment',
    'Initial Contact',
    'Requirement Discovery',

    'Proposal / Quotation',
    'Negotiation & Revision',
    'Approval Decision',
    'SOW / Contract Finalization',
    'Deal Won',
    'Client Onboarding',
    'Project / Workflow Setup',
    'Email Tracking',
    'Task Execution & Delivery',
    'Support / Tickets',
    'Invoice Generation',
    'Reports',
  ];

  String? _accessToken;
  String? _refreshToken;
  AuthUser? _currentUser;
  bool _loaded = false;

  AuthUser? get currentUser => _currentUser;
  bool get isSignedIn =>
      _accessToken != null && _accessToken!.isNotEmpty && _refreshToken != null;

  Future<void> initStorage() async {}

  Future<void> loadSession() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_tokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    final userJson = prefs.getString(_userKey);
    if (userJson != null && userJson.isNotEmpty) {
      _currentUser = AuthUser.fromJson(_map(jsonDecode(userJson)));
    }
    _loaded = true;
  }

  Future<bool> hasBootstrapUser() async {
    final data = await _request<Map<String, dynamic>>(
      '/auth/bootstrap/status',
      parser: _map,
    );
    return data['hasUsers'] == true;
  }

  Future<AuthResult> bootstrap({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _request<AuthResult>(
      '/auth/bootstrap',
      method: 'POST',
      body: {'name': name, 'email': email, 'password': password},
      parser: (data) => AuthResult.fromJson(_map(data)),
    );
    await _saveAuth(result);
    return result;
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _request<AuthResult>(
      '/auth/login',
      method: 'POST',
      body: {'email': email, 'password': password},
      parser: (data) => AuthResult.fromJson(_map(data)),
    );
    await _saveAuth(result);
    return result;
  }

  Future<void> signOut() async {
    final refreshToken = _refreshToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _request<Map<String, dynamic>>(
        '/auth/logout',
        method: 'POST',
        body: {'refreshToken': refreshToken},
        parser: _map,
        refreshOnUnauthorized: false,
      ).catchError((_) => <String, dynamic>{});
    }
    await _clearLocalSession();
  }

  bool canAccessModule(String module) {
    final user = _currentUser;
    if (user == null) return module == 'dashboard';
    final allowed = _modulesForRole(user.role);
    return allowed.contains('*') || allowed.contains(module);
  }

  bool canAccessRoute(String route) {
    return canAccessModule(_moduleForRoute(route));
  }

  bool canViewFinancials() {
    return {
      'SUPER_ADMIN',
      'MANAGEMENT_FOUNDER',
      'FOUNDER',
    }.contains(_roleKey(_currentUser?.role));
  }

  bool canManageTeam() {
    return {
      'SUPER_ADMIN',
      'MANAGEMENT_FOUNDER',
      'FOUNDER',
      'OPERATIONS_ADMIN',
      'MANAGER_TEAM_LEAD',
    }.contains(_roleKey(_currentUser?.role));
  }

  bool get isClientUser => _roleKey(_currentUser?.role) == 'CLIENT';

  bool get canClientAddClients =>
      isClientUser && (_currentUser?.subscriptionActive ?? false);

  bool get canCreateClients => !isClientUser || canClientAddClients;

  Future<DashboardSummary> dashboard() async {
    return _request<DashboardSummary>(
      '/dashboard/summary',
      parser: (data) => DashboardSummary.fromJson(_map(data)),
    );
  }

  Future<List<Client>> clients({String? query}) async {
    final suffix = query == null || query.trim().isEmpty
        ? ''
        : '?q=${Uri.encodeQueryComponent(query.trim())}';
    return _request<List<Client>>(
      '/clients$suffix',
      parser: (data) => _mapList(data).map(Client.fromJson).toList(),
    );
  }

  Future<List<Lead>> leads({String? query}) async {
    final suffix = query == null || query.trim().isEmpty
        ? ''
        : '?q=${Uri.encodeQueryComponent(query.trim())}';
    return _request<List<Lead>>(
      '/leads$suffix',
      parser: (data) => _mapList(data).map(Lead.fromJson).toList(),
    );
  }

  Future<Lead> lead(String id) async {
    return _request<Lead>(
      '/leads/$id',
      parser: (data) => Lead.fromJson(_map(data)),
    );
  }

  Future<Lead> createLead(Map<String, dynamic> payload) async {
    return _request<Lead>(
      '/leads',
      method: 'POST',
      body: payload,
      parser: (data) => Lead.fromJson(_map(data)),
    );
  }

  Future<Lead> updateLead(String id, Map<String, dynamic> payload) async {
    return _request<Lead>(
      '/leads/$id',
      method: 'PUT',
      body: payload,
      parser: (data) => Lead.fromJson(_map(data)),
    );
  }

  Future<void> deleteLead(String id) async {
    await _request<Map<String, dynamic>>(
      '/leads/$id',
      method: 'DELETE',
      parser: _map,
    );
  }

  Future<Client> convertLead(String id, Map<String, dynamic> payload) async {
    return _request<Client>(
      '/leads/$id/convert',
      method: 'POST',
      body: _clientPayload(payload),
      parser: (data) => Client.fromJson(_map(data)),
    );
  }

  Future<Client> createClient(Map<String, dynamic> payload) async {
    return _request<Client>(
      '/clients',
      method: 'POST',
      body: _clientPayload(payload),
      parser: (data) => Client.fromJson(_map(data)),
    );
  }

  Future<Client> updateClient(String id, Map<String, dynamic> payload) async {
    return _request<Client>(
      '/clients/$id',
      method: 'PUT',
      body: _clientPayload(payload),
      parser: (data) => Client.fromJson(_map(data)),
    );
  }

  Future<void> deleteClient(String id) async {
    await _request<Map<String, dynamic>>(
      '/clients/$id',
      method: 'DELETE',
      parser: _map,
    );
  }

  Future<ClientSummary> clientSummary(String id) async {
    return _request<ClientSummary>(
      '/clients/$id/summary',
      parser: (data) => ClientSummary.fromJson(_map(data)),
    );
  }

  Future<Contact> addClientContact(
    String clientId,
    Map<String, dynamic> payload,
  ) async {
    return _request<Contact>(
      '/clients/$clientId/contacts',
      method: 'POST',
      body: payload,
      parser: (data) => Contact.fromJson(_map(data)),
    );
  }



  Future<List<CrmTask>> tasks() async {
    return _request<List<CrmTask>>(
      '/tasks',
      parser: (data) => _mapList(data).map(CrmTask.fromJson).toList(),
    );
  }

  Future<CrmTask> createTask(Map<String, dynamic> payload) async {
    return _request<CrmTask>(
      '/tasks',
      method: 'POST',
      body: payload,
      parser: (data) => CrmTask.fromJson(_map(data)),
    );
  }

  Future<CrmTask> updateTask(String id, Map<String, dynamic> payload) async {
    return _request<CrmTask>(
      '/tasks/$id',
      method: 'PATCH',
      body: payload,
      parser: (data) => CrmTask.fromJson(_map(data)),
    );
  }

  Future<void> deleteTask(String id) async {
    await _request<Map<String, dynamic>>(
      '/tasks/$id',
      method: 'DELETE',
      parser: _map,
    );
  }

  Future<CrmTask> updateTaskStatus(String id, String status) async {
    return _request<CrmTask>(
      '/tasks/$id/status',
      method: 'PATCH',
      body: {'status': status},
      parser: (data) => CrmTask.fromJson(_map(data)),
    );
  }

  Future<CrmTask> addTaskComment(String id, String message) async {
    return _request<CrmTask>(
      '/tasks/$id/comments',
      method: 'POST',
      body: {
        'message': message,
        'author': _currentUser?.name,
        'authorId': _currentUser?.id,
      },
      parser: (data) => CrmTask.fromJson(_map(data)),
    );
  }

  Future<List<Project>> projects() async {
    return _request<List<Project>>(
      '/projects',
      parser: (data) => _mapList(data).map(Project.fromJson).toList(),
    );
  }

  Future<Project> createProject(Map<String, dynamic> payload) async {
    return _request<Project>(
      '/projects',
      method: 'POST',
      body: payload,
      parser: (data) => Project.fromJson(_map(data)),
    );
  }

  Future<Project> updateProject(String id, Map<String, dynamic> payload) async {
    return _request<Project>(
      '/projects/$id',
      method: 'PUT',
      body: payload,
      parser: (data) => Project.fromJson(_map(data)),
    );
  }

  Future<void> deleteProject(String id) async {
    await _request<Map<String, dynamic>>(
      '/projects/$id',
      method: 'DELETE',
      parser: _map,
    );
  }

  Future<ProjectSummary> projectSummary(String id) async {
    return _request<ProjectSummary>(
      '/projects/$id/summary',
      parser: (data) => ProjectSummary.fromJson(_map(data)),
    );
  }

  Future<Project> addProjectMilestone(
    String projectId,
    Map<String, dynamic> payload,
  ) async {
    return _request<Project>(
      '/projects/$projectId/milestones',
      method: 'POST',
      body: payload,
      parser: (data) => Project.fromJson(_map(data)),
    );
  }

  Future<Project> updateProjectMilestone(
    String projectId,
    String milestoneId,
    Map<String, dynamic> payload,
  ) async {
    return _request<Project>(
      '/projects/$projectId/milestones/$milestoneId',
      method: 'PATCH',
      body: payload,
      parser: (data) => Project.fromJson(_map(data)),
    );
  }

  Future<Project> uploadProjectMilestoneDocument(
    String projectId,
    String milestoneId,
    PlatformFile file, {
    bool refreshOnUnauthorized = true,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _apiUri('/projects/$projectId/milestones/$milestoneId/documents/upload'),
    );
    request.headers['Accept'] = 'application/json';
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }
    if (file.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
      );
    } else if (file.path != null && file.path!.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path!));
    } else {
      throw ApiException('Selected document could not be read.', 400);
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 401 &&
        refreshOnUnauthorized &&
        !request.url.path.contains('/auth/')) {
      final refreshed = await _refreshSession();
      if (refreshed) {
        return uploadProjectMilestoneDocument(
          projectId,
          milestoneId,
          file,
          refreshOnUnauthorized: false,
        );
      }
    }
    final decoded = response.body.isEmpty
        ? null
        : jsonDecode(response.body) as dynamic;
    final envelope = decoded is Map && decoded.containsKey('success')
        ? _map(decoded)
        : null;
    final success = envelope == null
        ? response.statusCode < 400
        : envelope['success'] == true;
    if (!success || response.statusCode >= 400) {
      final message = _string(
        envelope?['message'],
        response.reasonPhrase ?? 'Upload failed',
      );
      throw ApiException(message, response.statusCode);
    }
    return Project.fromJson(
      _map(envelope == null ? decoded : envelope['data']),
    );
  }

  Future<Project> deleteProjectMilestoneDocument(
    String projectId,
    String milestoneId,
    String documentId,
  ) async {
    return _request<Project>(
      '/projects/$projectId/milestones/$milestoneId/documents/$documentId',
      method: 'DELETE',
      parser: (data) => Project.fromJson(_map(data)),
    );
  }

  String projectMilestoneDocumentDownloadUrl(
    String projectId,
    String milestoneId,
    String documentId,
  ) {
    return '$_apiBaseUrl/projects/$projectId/milestones/$milestoneId/documents/$documentId/download';
  }

  Future<Project> addProjectTeamMember(String projectId, String member) async {
    return _request<Project>(
      '/projects/$projectId/team',
      method: 'POST',
      body: {'member': member},
      parser: (data) => Project.fromJson(_map(data)),
    );
  }

  Future<List<Ticket>> tickets() async {
    return _request<List<Ticket>>(
      '/tickets',
      parser: (data) => _mapList(data).map(Ticket.fromJson).toList(),
    );
  }

  Future<Ticket> createTicket(Map<String, dynamic> payload) async {
    return _request<Ticket>(
      '/tickets',
      method: 'POST',
      body: payload,
      parser: (data) => Ticket.fromJson(_map(data)),
    );
  }

  Future<Ticket> updateTicket(String id, Map<String, dynamic> payload) async {
    return _request<Ticket>(
      '/tickets/$id',
      method: 'PATCH',
      body: payload,
      parser: (data) => Ticket.fromJson(_map(data)),
    );
  }

  Future<void> deleteTicket(String id) async {
    await _request<Map<String, dynamic>>(
      '/tickets/$id',
      method: 'DELETE',
      parser: _map,
    );
  }

  Future<Ticket> updateTicketStatus(String id, String status) async {
    return _request<Ticket>(
      '/tickets/$id/status',
      method: 'PATCH',
      body: {'status': status},
      parser: (data) => Ticket.fromJson(_map(data)),
    );
  }

  Future<List<EmailMessage>> emails() async {
    return _request<List<EmailMessage>>(
      '/emails',
      parser: (data) => _mapList(data).map(EmailMessage.fromJson).toList(),
    );
  }

  Future<List<EmailAccountInfo>> emailAccounts() async {
    return _request<List<EmailAccountInfo>>(
      '/email-accounts',
      parser: (data) => _mapList(data).map(EmailAccountInfo.fromJson).toList(),
    );
  }

  Future<List<EmailProviderInfo>> emailProviders() async {
    return _request<List<EmailProviderInfo>>(
      '/email-providers',
      parser: (data) => _mapList(data).map(EmailProviderInfo.fromJson).toList(),
    );
  }

  Future<EmailSyncResult> syncEmailAccount(String id) async {
    return _request<EmailSyncResult>(
      '/email-accounts/$id/sync',
      method: 'POST',
      body: const <String, dynamic>{},
      parser: (data) => EmailSyncResult.fromJson(_map(data)),
    );
  }

  Future<EmailAccountInfo> disconnectEmailAccount(String id) async {
    return _request<EmailAccountInfo>(
      '/email-accounts/$id/disconnect',
      method: 'POST',
      body: const <String, dynamic>{},
      parser: (data) => EmailAccountInfo.fromJson(_map(data)),
    );
  }

  Future<EmailMessage> sendEmail(Map<String, dynamic> payload) async {
    return _request<EmailMessage>(
      '/emails/send',
      method: 'POST',
      body: payload,
      parser: (data) => EmailMessage.fromJson(_map(data)),
    );
  }

  Future<void> deleteEmail(String id) async {
    await _request<Map<String, dynamic>>(
      '/emails/$id',
      method: 'DELETE',
      parser: _map,
    );
  }

  Future<EmailAccountInfo> saveEmailAccount(
    Map<String, dynamic> payload,
  ) async {
    return _request<EmailAccountInfo>(
      '/email-accounts',
      method: 'POST',
      body: payload,
      parser: (data) => EmailAccountInfo.fromJson(_map(data)),
    );
  }

  Future<EmailProviderInfo> saveEmailProvider(
    Map<String, dynamic> payload,
  ) async {
    return _request<EmailProviderInfo>(
      '/email-providers',
      method: 'POST',
      body: payload,
      parser: (data) => EmailProviderInfo.fromJson(_map(data)),
    );
  }

  Future<Map<String, dynamic>> startEmailOAuth(
    String provider, {
    required String userId,
    required String email,
  }) async {
    return _request<Map<String, dynamic>>(
      '/email-accounts/oauth/$provider/start',
      method: 'POST',
      body: {
        'userId': userId,
        'email': email,
        'returnUrl': 'crm://email-connected',
      },
      parser: _map,
    );
  }

  Future<Map<String, List<WorkflowItem>>> workflowsByStage() async {
    final data = await _request<Map<String, dynamic>>(
      '/workflows/by-stage',
      parser: _map,
    );
    return {
      for (final stage in workflowStages)
        stage: _mapList(data[stage]).map(WorkflowItem.fromJson).toList(),
      for (final entry in data.entries)
        if (!workflowStages.contains(entry.key))
          entry.key: _mapList(entry.value).map(WorkflowItem.fromJson).toList(),
    };
  }

  Future<WorkflowItem> createWorkflow(Map<String, dynamic> payload) async {
    return _request<WorkflowItem>(
      '/workflows',
      method: 'POST',
      body: payload,
      parser: (data) => WorkflowItem.fromJson(_map(data)),
    );
  }

  Future<WorkflowItem> updateWorkflowStage(String id, String stage) async {
    return _request<WorkflowItem>(
      '/workflows/$id/stage',
      method: 'PATCH',
      body: {'stage': stage},
      parser: (data) => WorkflowItem.fromJson(_map(data)),
    );
  }

  Future<WorkflowItem> updateWorkflow(
    String id,
    Map<String, dynamic> payload,
  ) async {
    return _request<WorkflowItem>(
      '/workflows/$id',
      method: 'PATCH',
      body: payload,
      parser: (data) => WorkflowItem.fromJson(_map(data)),
    );
  }

  Future<void> deleteWorkflow(String id) async {
    await _request<Map<String, dynamic>>(
      '/workflows/$id',
      method: 'DELETE',
      parser: _map,
    );
  }

  Future<WorkflowItem> addWorkflowDocument(
    String id,
    Map<String, dynamic> payload,
  ) async {
    return _request<WorkflowItem>(
      '/workflows/$id/documents',
      method: 'POST',
      body: payload,
      parser: (data) => WorkflowItem.fromJson(_map(data)),
    );
  }

  Future<WorkflowItem> uploadWorkflowDocument(
    String id,
    PlatformFile file, {
    bool refreshOnUnauthorized = true,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _apiUri('/workflows/$id/documents/upload'),
    );
    request.headers['Accept'] = 'application/json';
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }
    if (file.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
      );
    } else if (file.path != null && file.path!.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path!));
    } else {
      throw ApiException('Selected document could not be read.', 400);
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 401 && refreshOnUnauthorized) {
      final refreshed = await _refreshSession();
      if (refreshed) {
        return uploadWorkflowDocument(id, file, refreshOnUnauthorized: false);
      }
    }
    final decoded = response.body.isEmpty
        ? null
        : jsonDecode(response.body) as dynamic;
    final envelope = decoded is Map && decoded.containsKey('success')
        ? _map(decoded)
        : null;
    final success = envelope == null
        ? response.statusCode < 400
        : envelope['success'] == true;
    if (!success || response.statusCode >= 400) {
      final message = _string(
        envelope?['message'],
        response.reasonPhrase ?? 'Document upload failed',
      );
      throw ApiException(message, response.statusCode);
    }
    return WorkflowItem.fromJson(
      _map(envelope == null ? decoded : envelope['data']),
    );
  }

  Future<WorkflowItem> deleteWorkflowDocument(
    String id,
    String documentId,
  ) async {
    return _request<WorkflowItem>(
      '/workflows/$id/documents/$documentId',
      method: 'DELETE',
      parser: (data) => WorkflowItem.fromJson(_map(data)),
    );
  }

  String workflowDocumentDownloadUrl(String workflowId, String documentId) {
    return '$_apiBaseUrl/workflows/$workflowId/documents/$documentId/download';
  }

  Future<ReportSummary> reports() async {
    return _request<ReportSummary>(
      '/reports/summary',
      parser: (data) => ReportSummary.fromJson(_map(data)),
    );
  }

  Future<SettingsSummary> settings() async {
    final summary = await _request<SettingsSummary>(
      '/settings',
      parser: (data) => SettingsSummary.fromJson(_map(data)),
    );
    final providers = await emailProviders().catchError(
      (_) => const <EmailProviderInfo>[],
    );
    return summary.copyWith(emailProviders: providers);
  }

  Future<TeamMember> saveUser(Map<String, dynamic> payload) async {
    return _request<TeamMember>(
      '/users',
      method: 'POST',
      body: payload,
      parser: (data) => TeamMember.fromJson(_map(data)),
    );
  }

  Future<RoleInfo> saveRole(Map<String, dynamic> payload) async {
    return _request<RoleInfo>(
      '/roles',
      method: 'POST',
      body: payload,
      parser: (data) => RoleInfo.fromJson(_map(data)),
    );
  }

  Future<DepartmentInfo> saveDepartment(Map<String, dynamic> payload) async {
    return _request<DepartmentInfo>(
      '/departments',
      method: 'POST',
      body: payload,
      parser: (data) => DepartmentInfo.fromJson(_map(data)),
    );
  }

  Future<Map<String, dynamic>> savePreference(
    String key,
    Map<String, dynamic> value,
  ) async {
    return _request<Map<String, dynamic>>(
      '/settings/preferences/$key',
      method: 'POST',
      body: {'value': value},
      parser: _map,
    );
  }

  Future<Map<String, dynamic>> health() async {
    return _request<Map<String, dynamic>>('/health', parser: _map);
  }

  Future<Map<String, dynamic>> profileSettings() async {
    return _request<Map<String, dynamic>>('/settings/profile', parser: _map);
  }

  Future<List<Map<String, dynamic>>> auditLogs() async {
    return _request<List<Map<String, dynamic>>>(
      '/audit-logs',
      parser: _mapList,
    );
  }

  Future<AuthUser> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return _request<AuthUser>(
      '/auth/change-password',
      method: 'POST',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
      parser: (data) => AuthUser.fromJson(_map(data)),
    );
  }

  Future<List<AppNotification>> notifications() async {
    return _request<List<AppNotification>>(
      '/notifications',
      parser: (data) => _mapList(data).map(AppNotification.fromJson).toList(),
    );
  }

  Future<T> _request<T>(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    required T Function(dynamic data) parser,
    bool refreshOnUnauthorized = true,
  }) async {
    final response = await _send(path, method: method, body: body);
    if (response.statusCode == 401 &&
        refreshOnUnauthorized &&
        !path.startsWith('/auth/')) {
      final refreshed = await _refreshSession();
      if (refreshed) {
        return _request<T>(
          path,
          method: method,
          body: body,
          parser: parser,
          refreshOnUnauthorized: false,
        );
      }
    }

    final decoded = response.body.isEmpty
        ? null
        : jsonDecode(response.body) as dynamic;
    final envelope = decoded is Map && decoded.containsKey('success')
        ? _map(decoded)
        : null;
    final success = envelope == null
        ? response.statusCode < 400
        : envelope['success'] == true;
    if (!success || response.statusCode >= 400) {
      final errors = _map(
        envelope?['errors'],
      ).values.where((value) => _string(value).isNotEmpty).join(', ');
      final message = _string(
        envelope?['message'],
        response.reasonPhrase ?? 'Request failed',
      );
      throw ApiException(
        errors.isEmpty ? message : '$message ($errors)',
        response.statusCode,
      );
    }
    return parser(envelope == null ? decoded : envelope['data']);
  }

  Future<http.Response> _send(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final request = http.Request(method, _apiUri(path));
    request.headers['Accept'] = 'application/json';
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    final streamed = await request.send();
    return http.Response.fromStream(streamed);
  }

  Future<bool> _refreshSession() async {
    final refreshToken = _refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final result = await _request<AuthResult>(
        '/auth/refresh',
        method: 'POST',
        body: {'refreshToken': refreshToken},
        parser: (data) => AuthResult.fromJson(_map(data)),
        refreshOnUnauthorized: false,
      );
      await _saveAuth(result);
      return true;
    } catch (_) {
      await _clearLocalSession();
      return false;
    }
  }

  Uri _apiUri(String path) {
    final base = _apiBaseUrl.endsWith('/')
        ? _apiBaseUrl.substring(0, _apiBaseUrl.length - 1)
        : _apiBaseUrl;
    return Uri.parse('$base$path');
  }

  Map<String, dynamic> _clientPayload(Map<String, dynamic> payload) {
    return {
      ...payload,
      'primaryContactName':
          payload['primaryContactName'] ?? payload['contactName'],
      'primaryContactEmail':
          payload['primaryContactEmail'] ?? payload['contactEmail'],
      'primaryContactPhone':
          payload['primaryContactPhone'] ?? payload['contactPhone'],
      'primaryContactDesignation':
          payload['primaryContactDesignation'] ??
          payload['contactDesignation'] ??
          'Primary Contact',
    };
  }

  Future<void> _saveAuth(AuthResult result) async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = result.accessToken;
    _refreshToken = result.refreshToken;
    _currentUser = result.user;
    await prefs.setString(_tokenKey, result.accessToken);
    await prefs.setString(_refreshTokenKey, result.refreshToken);
    await prefs.setString(_userKey, jsonEncode(result.user.toJson()));
  }

  Future<void> _clearLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
  }

  Set<String> _modulesForRole(String role) {
    switch (_roleKey(role)) {
      case 'SUPER_ADMIN':
      case 'MANAGEMENT_FOUNDER':
      case 'FOUNDER':
      case 'OPERATIONS_ADMIN':
        return const {'*'};
      case 'MANAGER_TEAM_LEAD':
        return const {
          'dashboard',
          'leads',
          'clients',
          'opportunities',
          'tasks',
          'projects',
          'emails',
          'workflows',
          'tickets',
          'reports',
          'settings',
        };
      case 'PROJECT_DELIVERY_USER':
        return const {
          'dashboard',
          'leads',
          'clients',
          'opportunities',
          'tasks',
          'projects',
          'emails',
          'workflows',
        };
      case 'SUPPORT_USER':
        return const {'dashboard', 'clients', 'tasks', 'emails', 'tickets'};
      case 'FINANCE_BILLING_USER':
        return const {
          'dashboard',
          'clients',
          'tasks',
          'projects',
          'emails',
          'workflows',
          'reports',
        };
      case 'VIEWER_AUDITOR':
        return const {'dashboard', 'clients', 'reports'};
      case 'CLIENT':
        return const {'dashboard', 'clients', 'projects'};
      default:
        return const {'dashboard'};
    }
  }

  String _moduleForRoute(String route) {
    if (route.startsWith('/more')) return 'more';
    if (route.startsWith('/leads')) return 'leads';
    if (route.startsWith('/clients')) return 'clients';
    if (route.startsWith('/opportunities')) return 'opportunities';
    if (route.startsWith('/tasks')) return 'tasks';
    if (route.startsWith('/projects')) return 'projects';
    if (route.startsWith('/emails')) return 'emails';
    if (route.startsWith('/workflows')) return 'workflows';
    if (route.startsWith('/tickets')) return 'tickets';
    if (route.startsWith('/reports')) return 'reports';
    if (route.startsWith('/settings')) return 'settings';
    return 'dashboard';
  }
}

String _roleKey(String? role) {
  return _string(role)
      .toUpperCase()
      .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is List) return value.map(_map).toList();
  return const [];
}

String _string(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'NA';
  if (parts.length == 1) {
    return parts.first
        .substring(0, parts.first.length.clamp(1, 2))
        .toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
