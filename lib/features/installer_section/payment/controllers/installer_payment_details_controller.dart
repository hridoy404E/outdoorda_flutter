import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/services/user_profile_api_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/installer_section/payment/models/installer_payment.dart';
import 'package:outdoorda_flutter/features/installer_section/payment/services/installer_payment_api_service.dart';

class InstallerPaymentDetailsController extends GetxController {
  InstallerPaymentDetailsController();

  final InstallerPaymentApiService _paymentApiService =
      InstallerPaymentApiService();
  final UserProfileApiService _userProfileApiService = UserProfileApiService();

  final RxList<InstallerPayment> payments = <InstallerPayment>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;

  final int limit = 10;
  int _skip = 0;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  double get totalAmount =>
      payments.fold(0, (total, payment) => total + payment.amount);

  int get succeededCount =>
      payments.where((payment) => payment.isSucceeded).length;

  int get pendingCount => payments.where((payment) => payment.isPending).length;

  @override
  void onInit() {
    super.onInit();
    loadPayments();
  }

  Future<void> loadPayments({bool refresh = false}) async {
    if (isLoading.value || isLoadingMore.value) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      errorMessage.value = AppStrings.authorizationRequired;
      return;
    }

    try {
      if (refresh) {
        _skip = 0;
        _hasMore = true;
        errorMessage.value = '';
      }

      isLoading.value = true;
      final userId = await _resolveUserId(authorization);
      final result = await _paymentApiService.fetchInstallerPayments(
        authorization: authorization,
        userId: userId,
        skip: _skip,
        limit: limit,
      );

      payments.assignAll(result);
      _skip = result.length;
      _hasMore = result.length >= limit;
      errorMessage.value = '';
    } catch (error) {
      AppLoggerHelper.error('Failed to load installer payments', error);
      errorMessage.value = 'Failed to load payment details';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPayments() => loadPayments(refresh: true);

  Future<void> loadMorePayments() async {
    if (!_hasMore || isLoading.value || isLoadingMore.value) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    try {
      isLoadingMore.value = true;
      final userId = await _resolveUserId(authorization);
      final result = await _paymentApiService.fetchInstallerPayments(
        authorization: authorization,
        userId: userId,
        skip: _skip,
        limit: limit,
      );

      payments.addAll(result);
      _skip += result.length;
      _hasMore = result.length >= limit;
    } catch (error) {
      AppLoggerHelper.error('Failed to load more installer payments', error);
      EasyLoading.showError('Failed to load more payments');
    } finally {
      isLoadingMore.value = false;
    }
  }

  String formatAmount(double amount) {
    return NumberFormat.currency(symbol: r'$', decimalDigits: 2).format(amount);
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM d, yyyy h:mm a').format(date.toLocal());
  }

  String shortId(String value) {
    final cleaned = value.trim();
    if (cleaned.length <= 12) return cleaned.isEmpty ? 'N/A' : cleaned;
    return '${cleaned.substring(0, 8)}...${cleaned.substring(cleaned.length - 4)}';
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return null;

    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }

  Future<String> _resolveUserId(String authorization) async {
    final cachedUserId = StorageService.userId?.trim();
    if (cachedUserId != null && cachedUserId.isNotEmpty) {
      return cachedUserId;
    }

    final profile = await _userProfileApiService.fetchCurrentUser(
      authorization: authorization,
    );
    final userId = profile.id.trim();
    if (userId.isEmpty) {
      throw Exception('Unable to resolve installer id');
    }
    return userId;
  }
}
