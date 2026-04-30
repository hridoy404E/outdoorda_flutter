import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/models/user_model.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/payment/models/admin_installer_payment.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/payment/services/admin_installer_payment_api_service.dart';

class AdminInstallerPaymentsController extends GetxController {
  AdminInstallerPaymentsController();

  final AdminInstallerPaymentApiService _paymentApiService =
      AdminInstallerPaymentApiService();

  final Rxn<UserModel> installer = Rxn<UserModel>();
  final RxList<AdminInstallerPayment> payments = <AdminInstallerPayment>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString markingPaymentId = ''.obs;
  final RxString markingPaymentAction = ''.obs;

  final int limit = 10;
  int _skip = 0;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  double get totalAmount =>
      payments.fold(0, (total, payment) => total + payment.amount);

  int get pendingCount => payments.where((payment) => payment.isPending).length;

  int get succeededCount =>
      payments.where((payment) => payment.isSucceeded).length;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is UserModel) {
      loadForInstaller(args);
    } else if (args is Map && args['installer'] is UserModel) {
      loadForInstaller(args['installer'] as UserModel);
    } else {
      errorMessage.value = 'Installer details missing';
    }
  }

  Future<void> loadForInstaller(UserModel user) async {
    installer.value = user;
    await loadPayments(refresh: true);
  }

  Future<void> loadPayments({bool refresh = false}) async {
    if (isLoading.value || isLoadingMore.value) return;

    final currentInstaller = installer.value;
    if (currentInstaller == null || currentInstaller.id.trim().isEmpty) {
      errorMessage.value = 'Installer ID missing';
      return;
    }

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
      final result = await _paymentApiService.fetchInstallerPayments(
        authorization: authorization,
        userId: currentInstaller.id,
        skip: _skip,
        limit: limit,
      );

      payments.assignAll(result);
      _skip = result.length;
      _hasMore = result.length >= limit;
      errorMessage.value = '';
    } catch (error) {
      AppLoggerHelper.error('Failed to load admin installer payments', error);
      errorMessage.value = 'Failed to load payment details';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPayments() => loadPayments(refresh: true);

  Future<void> loadMorePayments() async {
    if (!_hasMore || isLoading.value || isLoadingMore.value) return;

    final currentInstaller = installer.value;
    if (currentInstaller == null || currentInstaller.id.trim().isEmpty) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    try {
      isLoadingMore.value = true;
      final result = await _paymentApiService.fetchInstallerPayments(
        authorization: authorization,
        userId: currentInstaller.id,
        skip: _skip,
        limit: limit,
      );

      payments.addAll(result);
      _skip += result.length;
      _hasMore = result.length >= limit;
    } catch (error) {
      AppLoggerHelper.error('Failed to load more admin payments', error);
      EasyLoading.showError('Failed to load more payments');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> markPaymentReceived(AdminInstallerPayment payment) async {
    await _markPaymentAction(
      payment,
      action: 'received',
      fallbackStatus: 'received',
      loadingMessage: 'Marking payment received...',
      successMessage: 'Payment marked as received',
      failureMessage: 'Failed to mark payment received',
    );
  }

  Future<void> markPaymentRejected(AdminInstallerPayment payment) async {
    await _markPaymentAction(
      payment,
      action: 'rejected',
      fallbackStatus: 'rejected',
      loadingMessage: 'Marking payment not received...',
      successMessage: 'Payment marked as not received',
      failureMessage: 'Failed to mark payment not received',
    );
  }

  Future<void> _markPaymentAction(
    AdminInstallerPayment payment, {
    required String action,
    required String fallbackStatus,
    required String loadingMessage,
    required String successMessage,
    required String failureMessage,
  }) async {
    if (!payment.isPending || markingPaymentId.value.isNotEmpty) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    try {
      markingPaymentId.value = payment.id;
      markingPaymentAction.value = action;
      EasyLoading.show(status: loadingMessage);

      final updated = await _paymentApiService.markPaymentPaid(
        authorization: authorization,
        paymentId: payment.id,
        action: action,
      );

      final index = payments.indexWhere((item) => item.id == payment.id);
      if (index != -1) {
        payments[index] = updated ?? payment.copyWith(status: fallbackStatus);
      }

      EasyLoading.showSuccess(successMessage);
    } catch (error) {
      AppLoggerHelper.error(
        'Failed to mark installer payment action=$action',
        error,
      );
      EasyLoading.showError(failureMessage);
    } finally {
      markingPaymentId.value = '';
      markingPaymentAction.value = '';
      EasyLoading.dismiss();
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
}
