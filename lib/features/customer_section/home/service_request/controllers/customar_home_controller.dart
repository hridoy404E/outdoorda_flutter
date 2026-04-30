import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/controllers/new_service_controller.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/models/customer_post_model.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/models/review_model.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/models/service_request_model.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/services/customer_posts_api_service.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/services/customer_review_api_service.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/views/screens/new_service_screen.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';
import '../../help_center/screen/help_center_screen.dart';

/// Controller for managing service requests and reviews
class CustomarHomeController extends GetxController {
  // Observable lists for reactive UI updates
  final RxList<ServiceRequest> ongoingServices = <ServiceRequest>[].obs;
  final RxList<ServiceRequest> historyServices = <ServiceRequest>[].obs;
  final RxList<Review> happyTailsReviews = <Review>[].obs;
  final RxBool isLoading = false.obs;
  final CustomerPostsApiService _customerPostsApiService =
      CustomerPostsApiService();
  final CustomerReviewApiService _customerReviewApiService =
      CustomerReviewApiService();

  @override
  void onInit() {
    super.onInit();
    _loadCustomerHistory();
    _loadInstallerRatings();
    AppLoggerHelper.info('ServiceRequestController initialized');
  }

  /// Navigate to new request screen
  void onNewRequestTap() {
    AppLoggerHelper.debug('New Request button tapped');

    // Reset form and show bottom sheet
    final addServiceController = Get.find<NewServiceController>();
    addServiceController.resetForm();

    Get.bottomSheet(
      const NewServiceScreen(),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
    );
  }

  /// Navigate to messages screen
  void onMessageTap() {
    AppLoggerHelper.debug('Message button tapped');
    Get.toNamed(AppRoute.getMessageListScreen());
  }

  /// Navigate to help center screen
  void onHelpCenterTap() {
    AppLoggerHelper.debug('Help Center button tapped');
    Get.to(() => HelpCenterScreen());
  }

  /// Navigate to installer details
  void onInstallerTap(String installerId) {
    AppLoggerHelper.debug('Installer tapped: $installerId');
    // Get.toNamed(Routes.installerDetails, arguments: installerId);
  }

  /// Navigate to service details
  void onServiceTap(String serviceId) {
    AppLoggerHelper.debug('Service tapped: $serviceId');

    // Find the service by ID
    final service =
        historyServices.firstWhereOrNull((s) => s.id == serviceId) ??
        ongoingServices.firstWhereOrNull((s) => s.id == serviceId);

    if (service != null) {
      // Navigate to details screen with service data
      Get.toNamed(AppRoute.getRequestsDetailsScreen(), arguments: service);
    }
  }

  /// Navigate to profile
  void onProfileTap() {
    AppLoggerHelper.debug('Profile tapped');
    // Get.toNamed(Routes.profile);
  }

  void onViewAllTap() {
    try {
      AppLoggerHelper.info('View All tapped - navigating to All Requests');
      Get.toNamed(AppRoute.getAllRequestsScreen());
    } catch (error) {
      AppLoggerHelper.error('Failed to navigate to All Requests', error);
    }
  }

  Future<void> _loadCustomerHistory() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('History request missing authorization token');
      return;
    }

    isLoading.value = true;
    try {
      final posts = await _customerPostsApiService.fetchCustomerPosts(
        authorization: authorization,
      );
      // History list follows API response order directly.
      historyServices.assignAll(posts.map(_mapPostToServiceRequest).toList());

      // Ongoing home card still uses latest/priority selection.
      final sortedPostsForCard = [...posts]..sort(_comparePostsByLatestDesc);
      final latestCardPost = _selectHomeCardPost(sortedPostsForCard);
      if (latestCardPost != null) {
        ongoingServices.assignAll([_mapPostToServiceRequest(latestCardPost)]);
      } else {
        ongoingServices.clear();
      }
    } catch (error) {
      AppLoggerHelper.error('Failed to load customer history', error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshCustomerHistory() async {
    await _loadCustomerHistory();
    await _loadInstallerRatings();
  }

  Future<void> refreshHappyTailsReviews() async {
    await _loadInstallerRatings();
  }

  ServiceRequest? findServiceById(String serviceId) {
    return historyServices.firstWhereOrNull((s) => s.id == serviceId) ??
        ongoingServices.firstWhereOrNull((s) => s.id == serviceId);
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return null;
    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }

  Future<void> _loadInstallerRatings() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning(
        'Installer ratings request missing authorization',
      );
      happyTailsReviews.clear();
      return;
    }

    try {
      final ratings = await _customerReviewApiService.fetchInstallerRatings(
        authorization: authorization,
        limit: 20,
        skip: 0,
      );
      happyTailsReviews.assignAll(ratings);
    } catch (error) {
      AppLoggerHelper.error('Failed to load installer ratings', error);
      happyTailsReviews.clear();
    }
  }

  ServiceRequest _mapPostToServiceRequest(CustomerPostModel post) {
    final normalizedStatus = _normalizeStatus(post.status);
    return ServiceRequest(
      id: post.id,
      title: post.petName.isNotEmpty ? post.petName : '${post.petType} Service',
      address: post.address,
      installerName: _nullableText(post.installerId) ?? '',
      installerImageUrl: 'https://i.pravatar.cc/150?img=12',
      status: normalizedStatus,
      date: _formatDate(post.createdAt),
      price: _formatPrice(post.price),
      additionalInfo: _getAdditionalInfo(normalizedStatus),
      serviceType: post.petType,
      petName: post.petName,
      priceQuote: _formatPrice(post.price),
      scheduledDate: _parseDateTime(post.scheduledDate),
      installerNotes: _nullableText(post.note),
      additionalWorkPerformed: post.isAdditionalService,
      additionalWorkDescription: _nullableText(post.additionalServiceNote),
      customerSatisfied: post.isCustomerSatisfied,
      customerFeedback: _nullableText(post.customerSatisfactionNote),
    );
  }

  CustomerPostModel? _selectHomeCardPost(List<CustomerPostModel> posts) {
    if (posts.isEmpty) return null;

    final ongoingPosts = posts.where((post) {
      final status = _normalizeStatus(post.status);
      return _isOngoingStatus(status);
    }).toList();

    // If no ongoing job exists, show the latest post as fallback.
    if (ongoingPosts.isEmpty) return posts.first;

    final ongoingWithInstaller = ongoingPosts.where((post) {
      final installerId = _nullableText(post.installerId);
      return installerId != null && installerId.isNotEmpty;
    }).toList();

    return ongoingWithInstaller.isNotEmpty
        ? ongoingWithInstaller.first
        : ongoingPosts.first;
  }

  DateTime _effectivePostTime(CustomerPostModel post) {
    return _parseDateTime(post.updatedAt) ??
        _parseDateTime(post.createdAt) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  int _comparePostsByLatestDesc(CustomerPostModel a, CustomerPostModel b) {
    final byTime = _effectivePostTime(b).compareTo(_effectivePostTime(a));
    if (byTime != 0) return byTime;
    return b.id.compareTo(a.id);
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    return DateFormat('MMM d, yyyy').format(parsed);
  }

  DateTime? _parseDateTime(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return null;
    return DateTime.tryParse(rawDate.trim());
  }

  String? _nullableText(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _normalizeStatus(String status) {
    final cleaned = status.trim().toLowerCase();
    if (cleaned == 'pending') return 'Pending';
    if (cleaned == 'receiving bids' || cleaned == 'receiving_bids') {
      return 'Receiving Bids';
    }
    if (cleaned == 'installer assigned' || cleaned == 'installer_assigned') {
      return 'Installer Assigned';
    }
    if (cleaned == 'in progress' || cleaned == 'in_progress') {
      return AppStrings.inProgress;
    }
    if (cleaned == 'completed') return 'Completed';
    return cleaned.isNotEmpty
        ? cleaned[0].toUpperCase() + cleaned.substring(1)
        : cleaned;
  }

  bool _isOngoingStatus(String status) {
    return status == AppStrings.pending ||
        status == AppStrings.receivingBids ||
        status == AppStrings.installerAssigned ||
        status == AppStrings.inProgress;
  }

  String? _formatPrice(double? price) {
    if (price == null || price <= 0) return null;
    final priceInt = price.truncate();
    if (price == priceInt) {
      return '\$$priceInt';
    }
    return '\$${price.toStringAsFixed(2)}';
  }

  String? _getAdditionalInfo(String status) {
    switch (status) {
      case 'Pending':
        return AppStrings.noBidYet;
      case 'Receiving Bids':
        return AppStrings.bidsPending;
      default:
        return null;
    }
  }
}
