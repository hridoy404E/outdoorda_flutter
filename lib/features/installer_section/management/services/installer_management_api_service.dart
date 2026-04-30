import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/installer_section/management/models/installer_earnings_summary.dart';
import 'package:outdoorda_flutter/features/installer_section/management/models/installer_management_posts.dart';
import 'package:outdoorda_flutter/features/installer_section/management/models/management_job.dart';

class InstallerManagementApiService {
  InstallerManagementApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<void> updateInstallerPostStatus({
    required String postId,
    required String authorization,
    String? newStatus,
    DateTime? scheduledDate,
    String? note,
    bool? isAdditionalService,
    String? additionalServiceNote,
    bool? isCustomerSatisfied,
    String? customerSatisfactionNote,
  }) async {
    final endpoint = _buildPostUpdateEndpoint(postId);
    final body = <String, dynamic>{'note': note?.trim() ?? ''};

    if (newStatus != null && newStatus.trim().isNotEmpty) {
      body['new_status'] = newStatus.trim();
    }

    if (scheduledDate != null) {
      body['scheduled_date'] = scheduledDate.toUtc().toIso8601String();
    }
    if (isAdditionalService != null) {
      body['is_additional_service'] = isAdditionalService;
    }
    if (additionalServiceNote != null) {
      body['additional_service_note'] = additionalServiceNote.trim();
    }
    if (isCustomerSatisfied != null) {
      body['is_customer_satisfied'] = isCustomerSatisfied;
    }
    if (customerSatisfactionNote != null) {
      body['customer_satisfaction_note'] = customerSatisfactionNote.trim();
    }

    AppLoggerHelper.info(
      'InstallerManagementApiService: updating post=$postId status=$newStatus '
      'body=$body',
    );

    final response = await _networkCaller.patchRequest(
      endpoint,
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: body,
    );

    AppLoggerHelper.debug(
      'InstallerManagementApiService.updateInstallerPostStatus: '
      'status=${response.statusCode} '
      'success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess ||
        (response.statusCode >= 200 && response.statusCode < 300)) {
      return;
    }

    throw Exception(
      _extractStatusUpdateErrorMessage(response.responseData) ??
          (response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Failed to update installer post'),
    );
  }

  Future<void> submitInstallerBid({
    required String postId,
    required String authorization,
    required double price,
    String? note,
  }) async {
    final endpoint = _buildPostBidEndpoint(postId);
    AppLoggerHelper.info(
      'InstallerManagementApiService: submitting bid for post=$postId price=$price',
    );

    final response = await _networkCaller.postRequest(
      endpoint,
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: {'price': price, 'note': note?.trim() ?? ''},
    );

    AppLoggerHelper.debug(
      'InstallerManagementApiService.submitInstallerBid: '
      'status=${response.statusCode} '
      'success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess ||
        (response.statusCode >= 200 && response.statusCode < 300)) {
      return;
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : _extractErrorMessage(response.responseData),
    );
  }

  Future<InstallerManagementPosts> fetchInstallerPosts({
    required String authorization,
  }) async {
    AppLoggerHelper.info(
      'InstallerManagementApiService: fetching installer posts',
    );

    final response = await _networkCaller.getRequest(
      ApiEndpoints.customerPosts,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'InstallerManagementApiService.fetchInstallerPosts: '
      'status=${response.statusCode} '
      'success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return _extractGroupedPosts(
        response.responseData as Map<String, dynamic>,
      );
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : _extractErrorMessage(response.responseData),
    );
  }

  Future<List<ManagementJob>> fetchAdminAssignedPosts({
    required String authorization,
    int offset = 0,
    int limit = 10,
  }) async {
    AppLoggerHelper.info(
      'InstallerManagementApiService: fetching admin assigned posts',
    );

    final response = await _networkCaller.getRequest(
      ApiEndpoints.adminPostsAdmin,
      token: authorization,
      headers: {'accept': 'application/json'},
      queryParams: {'offset': offset, 'limit': limit},
    );

    AppLoggerHelper.debug(
      'InstallerManagementApiService.fetchAdminAssignedPosts: '
      'status=${response.statusCode} '
      'success=${response.isSuccess} '
      'offset=$offset limit=$limit body=${response.responseData}',
    );

    if (response.isSuccess) {
      final items = _extractAdminPostsItems(response.responseData);
      return items
          .map((item) => _toManagementJob(item, isAssignedPost: false))
          .toList();
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : _extractErrorMessage(response.responseData),
    );
  }

  Future<void> acceptAdminAssignedPost({
    required String postId,
    required String authorization,
  }) async {
    await acceptInstallerPost(postId: postId, authorization: authorization);
  }

  Future<void> acceptInstallerPost({
    required String postId,
    required String authorization,
  }) async {
    final endpoint = _buildPostAcceptEndpoint(postId);

    AppLoggerHelper.info(
      'InstallerManagementApiService: accepting installer post=$postId',
    );

    final response = await _networkCaller.postRequest(
      endpoint,
      token: authorization,
      headers: {'accept': 'application/json'},
      formUrlEncoded: true,
      body: const {},
    );

    AppLoggerHelper.debug(
      'InstallerManagementApiService.acceptInstallerPost: '
      'status=${response.statusCode} '
      'success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess ||
        (response.statusCode >= 200 && response.statusCode < 300)) {
      return;
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : _extractErrorMessage(response.responseData),
    );
  }

  Future<InstallerEarningsSummary> fetchMonthlyEarningsSummary({
    required String authorization,
  }) async {
    AppLoggerHelper.info(
      'InstallerManagementApiService: fetching monthly earnings summary',
    );

    final response = await _networkCaller.getRequest(
      ApiEndpoints.installerEarnings,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'InstallerManagementApiService.fetchMonthlyEarningsSummary: '
      'status=${response.statusCode} '
      'success=${response.isSuccess} '
      'body=${response.responseData}',
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return InstallerEarningsSummary.fromJson(
        response.responseData as Map<String, dynamic>,
      );
    }

    throw Exception(
      response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Unable to load installer earnings summary',
    );
  }

  InstallerManagementPosts _extractGroupedPosts(Map<String, dynamic> data) {
    final newItems = _extractItems(data['new_posts']);
    List<Map<String, dynamic>> assignedItems = _extractItems(
      data['assigned_post'],
    );

    // Backward compatible fallback for older payloads returning one list.
    if (newItems.isEmpty && assignedItems.isEmpty) {
      assignedItems = _extractItems(data['posts']);
    }

    return InstallerManagementPosts(
      newPosts: newItems
          .map((item) => _toManagementJob(item, isAssignedPost: false))
          .toList(),
      assignedPosts: assignedItems
          .map((item) => _toManagementJob(item, isAssignedPost: true))
          .toList(),
    );
  }

  List<Map<String, dynamic>> _extractItems(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  List<Map<String, dynamic>> _extractAdminPostsItems(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }

    if (data is Map<String, dynamic>) {
      const listKeys = [
        'posts',
        'results',
        'items',
        'data',
        'assigned_post',
        'new_posts',
      ];

      for (final key in listKeys) {
        final value = data[key];
        if (value is List) {
          return value.whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    return const [];
  }

  ManagementJob _toManagementJob(
    Map<String, dynamic> json, {
    required bool isAssignedPost,
  }) {
    final id = _firstNotEmpty([json['id']?.toString()]) ?? '';
    final createdAtRaw = _firstNotEmpty([
      json['created_at']?.toString(),
      json['updated_at']?.toString(),
    ]);
    final createdAt = createdAtRaw != null
        ? DateTime.tryParse(createdAtRaw)
        : null;

    final installationSurface = _firstNotEmpty([
      json['installation_surface']?.toString(),
      json['door_type']?.toString(),
    ]);

    final statusRaw = _firstNotEmpty([json['status']?.toString()]) ?? '';
    final price = _toDouble(json['price']);
    final addressLine1 = _firstNotEmpty([json['address_line_1']?.toString()]);
    final addressLine2 = _firstNotEmpty([json['address_line_2']?.toString()]);
    final city = _firstNotEmpty([json['city']?.toString()]);
    final state = _firstNotEmpty([json['state']?.toString()]);
    final zipCode = _firstNotEmpty([json['zip_code']?.toString()]);
    final country = _firstNotEmpty([json['country']?.toString()]);
    final composedLocation = _composeLocation(
      city: city,
      state: state,
      country: country,
    );
    final photos = (json['photos'] as List? ?? const [])
        .map((e) => _normalizeMediaUrl(e.toString()))
        .where((e) => e.trim().isNotEmpty)
        .toList();

    return ManagementJob(
      id: id,
      isAssignedPost: isAssignedPost,
      jobNumber:
          _firstNotEmpty([
            json['job_number']?.toString(),
            json['job_no']?.toString(),
          ]) ??
          _buildShortJobNumber(id),
      customerName:
          _firstNotEmpty([
            json['customer_name']?.toString(),
            json['pet_name']?.toString(),
            json['customer_id']?.toString(),
          ]) ??
          'Unknown Customer',
      price: price,
      location:
          _firstNotEmpty([
            json['Address']?.toString(),
            json['address']?.toString(),
            json['location']?.toString(),
            composedLocation,
            addressLine1,
          ]) ??
          '-',
      doorType: _toTitleCase(installationSurface ?? 'Unknown'),
      status: _mapStatus(statusRaw, isAssignedPost: isAssignedPost),
      statusLabel: _mapStatusLabel(statusRaw, isAssignedPost: isAssignedPost),
      bidCount: _toInt(json['bid_count'] ?? json['bids_count']),
      createdAt: createdAt ?? DateTime.now(),
      petDoorDescription:
          _firstNotEmpty([
            json['pet_name']?.toString(),
            json['pet_type']?.toString(),
            json['pet_door_description']?.toString(),
          ]) ??
          '-',
      installationType: _buildInstallationType(installationSurface),
      adminEstimatedPrice: price,
      addressLine1: addressLine1 ?? '',
      addressLine2: addressLine2 ?? '',
      city: city ?? '',
      state: state ?? '',
      zipCode: zipCode ?? '',
      country: country ?? '',
      petName: _firstNotEmpty([json['pet_name']?.toString()]) ?? '',
      petType: _firstNotEmpty([json['pet_type']?.toString()]) ?? '',
      petSize: _firstNotEmpty([json['size']?.toString()]) ?? '',
      jobNotes:
          _firstNotEmpty([
            json['note']?.toString(),
            json['additional_service_note']?.toString(),
            json['job_notes']?.toString(),
          ]) ??
          '',
      sitePhotos: photos,
      scheduledDate: _parseDate(json['scheduled_date']),
      jobStatusNotes: _firstNotEmpty([
        json['job_status_notes']?.toString(),
        json['note']?.toString(),
      ]),
      additionalWorkAnswer: _toBool(
        json['is_additional_service'] ?? json['additional_work_answer'],
      ),
      additionalWorkNotes: json['additional_service_note']?.toString(),
      customerSatisfiedAnswer: _toBool(
        json['is_customer_satisfied'] ?? json['customer_satisfied_answer'],
      ),
      customerSatisfiedNotes: _firstNotEmpty([
        json['customer_satisfaction_note']?.toString(),
        json['customer_feedback']?.toString(),
      ]),
    );
  }

  String _composeLocation({String? city, String? state, String? country}) {
    final parts = <String>[
      if (city != null && city.trim().isNotEmpty) city,
      if (state != null && state.trim().isNotEmpty) state,
      if (country != null && country.trim().isNotEmpty) country,
    ];
    return parts.join(', ');
  }

  JobStatus _mapStatus(String status, {required bool isAssignedPost}) {
    final cleaned = status.trim().toLowerCase();

    if (cleaned == 'completed') return JobStatus.completed;

    if (cleaned == 'in_progress' || cleaned == 'in progress') {
      return JobStatus.inProgress;
    }

    if (cleaned == 'installer_assigned' || cleaned == 'assigned') {
      return JobStatus.assigned;
    }

    if (cleaned == 'pending' ||
        cleaned == 'receiving_bids' ||
        cleaned == 'receiving bids') {
      return isAssignedPost ? JobStatus.assigned : JobStatus.inProgress;
    }

    return isAssignedPost ? JobStatus.assigned : JobStatus.inProgress;
  }

  String _mapStatusLabel(String status, {required bool isAssignedPost}) {
    final cleaned = status.trim().toLowerCase();
    if (cleaned.isEmpty) return '';
    return _toTitleCase(cleaned.replaceAll('_', ' '));
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail']?.toString();
      final message = data['message']?.toString();
      final source = detail ?? message;
      if (source != null && source.trim().isNotEmpty) {
        return source;
      }
    }
    return 'Failed to load installer posts';
  }

  String? _extractStatusUpdateErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail']?.toString();
      if (detail != null && detail.trim().isNotEmpty) {
        return detail.trim();
      }
      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return null;
  }

  DateTime? _parseDate(dynamic raw) {
    final text = raw?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  int? _toInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
  }

  double _toDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '') ?? 0.0;
  }

  bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return null;
    final text = value.toString().trim().toLowerCase();
    if (text == 'true') return true;
    if (text == 'false') return false;
    return null;
  }

  String? _firstNotEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty && value.trim() != 'null') {
        return value.trim();
      }
    }
    return null;
  }

  String _buildShortJobNumber(String id) {
    if (id.trim().isEmpty) return 'JOB';
    final compact = id.replaceAll('-', '').toUpperCase();
    return compact.length <= 8 ? compact : compact.substring(0, 8);
  }

  String _toTitleCase(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return cleaned;

    final words = cleaned.replaceAll('_', ' ').toLowerCase().split(' ');
    return words
        .where((w) => w.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  String _buildInstallationType(String? surface) {
    final base = _toTitleCase(surface ?? '');
    if (base.isEmpty) return 'Installation';
    if (base.toLowerCase().contains('installation')) return base;
    return '$base Installation';
  }

  String _normalizeMediaUrl(String rawUrl) {
    final url = rawUrl.trim();
    if (url.isEmpty) return '';

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('//')) {
      return 'https:$url';
    }

    if (url.startsWith('/')) {
      return '${ApiEndpoints.baseUrl}$url';
    }

    return '${ApiEndpoints.baseUrl}/$url';
  }

  String _buildPostBidEndpoint(String postId) {
    final cleanedId = postId.trim();
    if (cleanedId.isEmpty) {
      throw Exception('Invalid post id');
    }
    return '${ApiEndpoints.customerPosts}$cleanedId/bids/';
  }

  String _buildPostUpdateEndpoint(String postId) {
    final cleanedId = postId.trim();
    if (cleanedId.isEmpty) {
      throw Exception('Invalid post id');
    }
    return '${ApiEndpoints.customerPosts}$cleanedId/update/';
  }

  String _buildPostAcceptEndpoint(String postId) {
    final cleanedId = postId.trim();
    if (cleanedId.isEmpty) {
      throw Exception('Invalid post id');
    }
    return '${ApiEndpoints.baseUrl}/customer/post/$cleanedId/accept/';
  }
}
