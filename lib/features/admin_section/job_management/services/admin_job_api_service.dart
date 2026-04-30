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

    return ManagementJob(
      id: id,
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

  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail']?.toString();
      final message = data['message']?.toString();
      final source = detail ?? message;
      if (source != null && source.trim().isNotEmpty) {
        return source;
      }
    }
    return 'Failed to load jobs';
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
}
