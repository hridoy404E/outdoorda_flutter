// ignore_for_file: depend_on_referenced_packages

import 'package:http/http.dart' as http;
import 'package:outdoorda_flutter/core/services/network_caller.dart';
import 'package:outdoorda_flutter/core/utils/constants/api_endpoints.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/installer_section/management/models/management_job.dart';

class AdminJobApiService {
  AdminJobApiService();

  final NetworkCaller _networkCaller = NetworkCaller();

  Future<List<ManagementJob>> fetchRecentJobs({
    required String authorization,
    required int offset,
    required int limit,
  }) async {
    final response = await _networkCaller.getRequest(
      ApiEndpoints.adminRecentJobs,
      token: authorization,
      headers: {'accept': 'application/json'},
      queryParams: {'offset': offset, 'limit': limit},
    );

    AppLoggerHelper.debug(
      'AdminJobApiService.fetchRecentJobs: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'offset=$offset limit=$limit body=${response.responseData}',
    );

    if (response.isSuccess) {
      final items = _extractItems(response.responseData);
      return items.map(_toManagementJob).toList();
    }

    if (response.statusCode == 404) {
      final detail = response.responseData is Map<String, dynamic>
          ? (response.responseData as Map<String, dynamic>)['detail']
                ?.toString()
                .toLowerCase()
          : '';
      if ((detail ?? '').contains('job')) {
        return [];
      }
    }

    throw Exception(_extractErrorMessage(response.responseData));
  }

  List<Map<String, dynamic>> _extractItems(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }

    if (data is Map<String, dynamic>) {
      if (data['jobs'] is List) {
        return (data['jobs'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      if (data['results'] is List) {
        return (data['results'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    }

    return const [];
  }

  ManagementJob _toManagementJob(Map<String, dynamic> json) {
    final id = _firstNotEmpty([json['id']?.toString()]) ?? '';
    final createdAtRaw = _firstNotEmpty([json['created_at']?.toString()]);
    final createdAt = createdAtRaw != null
        ? DateTime.tryParse(createdAtRaw)
        : null;

    final installationSurface = _firstNotEmpty([
      json['installation_surface']?.toString(),
      json['door_type']?.toString(),
    ]);

    final statusRaw = _firstNotEmpty([json['status']?.toString()]) ?? '';
    final price = _toDouble(json['price']);
    final photos = (json['photos'] as List? ?? const [])
        .map((e) => _normalizeMediaUrl(e.toString()))
        .where((e) => e.trim().isNotEmpty)
        .toList();

    final addressLine1 = _firstNotEmpty([json['address_line_1']?.toString()]);
    final addressLine2 = _firstNotEmpty([json['address_line_2']?.toString()]);
    final city = _firstNotEmpty([json['city']?.toString()]);
    final state = _firstNotEmpty([json['state']?.toString()]);
    final zipCode = _firstNotEmpty([json['zip_code']?.toString()]);
    final country = _firstNotEmpty([json['country']?.toString()]);
    final composedLocation = _composeLocation(
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      zipCode: zipCode,
      country: country,
    );

    return ManagementJob(
      id: id,
      jobNumber:
          _firstNotEmpty([
            json['job_number']?.toString(),
            json['job_no']?.toString(),
          ]) ??
          _buildShortJobNumber(id),
      customerName: _extractCustomerName(json),
      price: price,
      location:
          _firstNotEmpty([
            json['Address']?.toString(),
            json['address']?.toString(),
            json['location']?.toString(),
            composedLocation,
          ]) ??
          '-',
      doorType: _toTitleCase(installationSurface ?? 'Unknown'),
      status: JobStatus.fromString(statusRaw),
      statusLabel: _statusLabelForBadge(statusRaw),
      bidCount: _toInt(json['bid_count']),
      createdAt: createdAt ?? DateTime.now(),
      petDoorDescription:
          _firstNotEmpty([
            json['pet_name']?.toString(),
            json['pet_type']?.toString(),
            json['pet_door_description']?.toString(),
          ]) ??
          '-',
      installationType: _toTitleCase(installationSurface ?? ''),
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
      jobStatusNotes: json['job_status_notes']?.toString(),
      additionalWorkAnswer: json['is_additional_service'] as bool?,
      additionalWorkNotes: json['additional_service_note']?.toString(),
      customerSatisfiedAnswer: json['is_customer_satisfied'] as bool?,
      customerSatisfiedNotes: json['customer_satisfaction_note']?.toString(),
    );
  }

  Future<void> deletePost({
    required String authorization,
    required String postId,
  }) async {
    final baseUrl = ApiEndpoints.adminPostsAdmin.endsWith('/')
        ? ApiEndpoints.adminPostsAdmin
        : '${ApiEndpoints.adminPostsAdmin}/';
    final url = '$baseUrl$postId/';

    final response = await _networkCaller.deleteRequest(
      url,
      token: authorization,
      headers: {'accept': 'application/json'},
    );

    AppLoggerHelper.debug(
      'AdminJobApiService.deletePost: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'postId=$postId body=${response.responseData}',
    );

    if (response.isSuccess ||
        (response.statusCode >= 200 && response.statusCode < 300)) {
      return;
    }

    throw Exception(
      _extractErrorMessage(
        response.responseData,
        fallback: 'Failed to delete post',
      ),
    );
  }

  Future<void> updateRecentJob({
    required String authorization,
    required String postId,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    final baseUrl = ApiEndpoints.adminRecentJobs.endsWith('/')
        ? ApiEndpoints.adminRecentJobs
        : '${ApiEndpoints.adminRecentJobs}/';
    final url = '$baseUrl$postId/';

    final response = await _networkCaller.multipartRequest(
      url,
      method: 'PATCH',
      token: authorization,
      headers: {'accept': 'application/json'},
      fields: fields,
      files: files,
    );

    AppLoggerHelper.debug(
      'AdminJobApiService.updateRecentJob: '
      'status=${response.statusCode} success=${response.isSuccess} '
      'postId=$postId body=${response.responseData}',
    );

    if (response.isSuccess ||
        (response.statusCode >= 200 && response.statusCode < 300)) {
      return;
    }

    throw Exception(
      _extractErrorMessage(
        response.responseData,
        fallback: 'Failed to update job',
      ),
    );
  }

  String _extractErrorMessage(
    dynamic data, {
    String fallback = 'Failed to load jobs',
  }) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail']?.toString();
      final message = data['message']?.toString();
      final source = detail ?? message;
      if (source != null && source.trim().isNotEmpty) {
        return source;
      }
    }
    return fallback;
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

  String _statusLabelForBadge(String statusRaw) {
    final cleaned = statusRaw.trim().toLowerCase();
    if (cleaned == 'receiving_bids' || cleaned == 'receiving bids') {
      return 'Receiving Bids';
    }
    if (cleaned == 'installer_assigned' || cleaned == 'installer assigned') {
      return 'Installer Assigned';
    }
    if (cleaned == 'pending') return 'Pending';
    return '';
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

  String _composeLocation({
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zipCode,
    String? country,
  }) {
    final parts = <String>[
      if (addressLine1 != null && addressLine1.trim().isNotEmpty) addressLine1,
      if (addressLine2 != null && addressLine2.trim().isNotEmpty) addressLine2,
      if (city != null && city.trim().isNotEmpty) city,
      if (state != null && state.trim().isNotEmpty) state,
      if (zipCode != null && zipCode.trim().isNotEmpty) zipCode,
      if (country != null && country.trim().isNotEmpty) country,
    ];
    return parts.join(', ');
  }

  String _extractCustomerName(Map<String, dynamic> json) {
    final nestedKeys = [
      'cust_info',
      'custInfo',
      'customer_info',
      'customerInfo',
      'customer',
      'Customer',
      'user',
      'User',
      'user_info',
      'userInfo',
      'client',
      'Client',
      'owner',
      'Owner',
      'posted_by',
      'postedBy',
      'created_by',
      'createdBy',
    ];

    final innerNameKeys = [
      'cust_name',
      'custName',
      'customer_name',
      'customerName',
      'name',
      'full_name',
      'fullName',
      'first_name',
      'firstName',
      'last_name',
      'lastName',
      'display_name',
      'displayName',
    ];

    for (final nKey in nestedKeys) {
      final obj = json[nKey];
      if (obj is Map<String, dynamic>) {
        final first = _cleanCustomerName(
          obj['first_name']?.toString() ?? obj['firstName']?.toString(),
        );
        final last = _cleanCustomerName(
          obj['last_name']?.toString() ?? obj['lastName']?.toString(),
        );
        if (first != null && last != null) {
          final combined = '$first $last';
          if (_cleanCustomerName(combined) != null) return combined;
        }

        for (final iKey in innerNameKeys) {
          final val = _cleanCustomerName(obj[iKey]?.toString());
          if (val != null) return val;
        }
      }
    }

    final topFirst = _cleanCustomerName(
      json['first_name']?.toString() ?? json['firstName']?.toString(),
    );
    final topLast = _cleanCustomerName(
      json['last_name']?.toString() ?? json['lastName']?.toString(),
    );
    if (topFirst != null && topLast != null) {
      final combined = '$topFirst $topLast';
      if (_cleanCustomerName(combined) != null) return combined;
    }

    final topKeys = [
      'cust_name',
      'custName',
      'customer_name',
      'customerName',
      'client_name',
      'clientName',
      'user_name',
      'userName',
      'full_name',
      'fullName',
      'owner_name',
      'ownerName',
      'display_name',
      'displayName',
      'name',
    ];

    for (final key in topKeys) {
      final val = _cleanCustomerName(json[key]?.toString());
      if (val != null) return val;
    }

    final petName = _cleanCustomerName(
      json['pet_name']?.toString() ?? json['petName']?.toString(),
    );
    if (petName != null) return petName;

    return 'Customer';
  }

  static String? _cleanCustomerName(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty ||
        trimmed == 'null' ||
        trimmed == 'undefined' ||
        trimmed == 'None') {
      return null;
    }
    final lower = trimmed.toLowerCase();
    if (lower.contains('admin') ||
        lower.contains('administrator') ||
        lower == 'system' ||
        lower == 'customer') {
      return null;
    }
    return trimmed;
  }
}
