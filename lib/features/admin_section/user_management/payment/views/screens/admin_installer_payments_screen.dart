import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/models/user_model.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/payment/controllers/admin_installer_payments_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/payment/models/admin_installer_payment.dart';

class AdminInstallerPaymentsScreen extends StatelessWidget {
  const AdminInstallerPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminInstallerPaymentsController>();
    final args = Get.arguments;
    final routeInstaller = args is UserModel
        ? args
        : (args is Map && args['installer'] is UserModel
              ? args['installer'] as UserModel
              : null);
    if (routeInstaller != null &&
        controller.installer.value?.id != routeInstaller.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadForInstaller(routeInstaller);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        surfaceTintColor: AppColors.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Installer Payments',
          style: figtreeTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.payments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.payments.isEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: () => controller.loadPayments(refresh: true),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshPayments,
          color: AppColors.gradientEnd,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
            children: [
              _InstallerHeader(controller: controller),
              SizedBox(height: 14.h),
              _PaymentSummary(controller: controller),
              SizedBox(height: 18.h),
              Text(
                'Payment Records',
                style: figtreeTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 10.h),
              if (controller.payments.isEmpty)
                const _EmptyPayments()
              else
                ...controller.payments.map(
                  (payment) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _PaymentCard(
                      payment: payment,
                      controller: controller,
                    ),
                  ),
                ),
              if (controller.hasMore) ...[
                SizedBox(height: 4.h),
                _LoadMoreButton(controller: controller),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _InstallerHeader extends StatelessWidget {
  const _InstallerHeader({required this.controller});

  final AdminInstallerPaymentsController controller;

  @override
  Widget build(BuildContext context) {
    final installer = controller.installer.value;
    final imageUrl = installer?.profileImageUrl.trim() ?? '';

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFEBEFF1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardBackground,
              image: imageUrl.isNotEmpty
                  ? DecorationImage(image: NetworkImage(imageUrl))
                  : null,
            ),
            child: imageUrl.isEmpty
                ? Icon(Icons.person, size: 24.r, color: AppColors.neutral400)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  installer?.name.trim().isNotEmpty == true
                      ? installer!.name
                      : 'Installer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: figtreeTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  installer?.id.trim().isNotEmpty == true
                      ? installer!.id
                      : 'Installer ID unavailable',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: figtreeTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.controller});

  final AdminInstallerPaymentsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.payments_outlined,
                  size: 21.r,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Payments',
                      style: figtreeTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      controller.formatAmount(controller.totalAmount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: figtreeTextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Succeeded',
                  value: controller.succeededCount.toString(),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _SummaryMetric(
                  label: 'Pending',
                  value: controller.pendingCount.toString(),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _SummaryMetric(
                  label: 'Records',
                  value: controller.payments.length.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: figtreeTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: figtreeTextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment, required this.controller});

  final AdminInstallerPayment payment;
  final AdminInstallerPaymentsController controller;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(payment.status);

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFEBEFF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  payment.isSucceeded
                      ? Icons.check_circle_outline
                      : payment.isRejected
                      ? Icons.cancel_outlined
                      : Icons.schedule_outlined,
                  size: 20.r,
                  color: statusColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.formatAmount(payment.amount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: figtreeTextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      controller.formatDate(payment.createdAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: figtreeTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(label: payment.statusLabel, color: statusColor),
            ],
          ),
          SizedBox(height: 14.h),
          Container(height: 1.h, color: const Color(0xFFEBEFF1)),
          SizedBox(height: 12.h),
          _DetailRow(label: 'Payment Type', value: payment.paymentTypeLabel),
          SizedBox(height: 8.h),
          _DetailRow(
            label: 'Payment ID',
            value: controller.shortId(payment.id),
          ),
          SizedBox(height: 8.h),
          _DetailRow(label: 'Installer ID', value: payment.installerId),
          if (payment.stripePaymentIntentId.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            _DetailRow(
              label: 'Stripe Intent',
              value: controller.shortId(payment.stripePaymentIntentId),
            ),
          ],
          SizedBox(height: 14.h),
          Obx(() {
            final isMarking = controller.markingPaymentId.value == payment.id;
            final markingAction = controller.markingPaymentAction.value;

            if (payment.isFailed) return const SizedBox.shrink();

            if (!payment.isPending) {
              return SizedBox(
                width: double.infinity,
                height: 42.h,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: AppColors.cardBackground,
                    disabledForegroundColor: AppColors.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    payment.isRejected ? 'Not Received' : 'Received',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: figtreeTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _PaymentDecisionButton(
                    label: 'Receive',
                    color: AppColors.gradientEnd,
                    isPrimary: true,
                    isLoading: isMarking && markingAction == 'received',
                    onPressed: isMarking
                        ? null
                        : () => controller.markPaymentReceived(payment),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _PaymentDecisionButton(
                    label: 'Not Receive',
                    color: AppColors.error,
                    isPrimary: false,
                    isLoading: isMarking && markingAction == 'rejected',
                    onPressed: isMarking
                        ? null
                        : () => controller.markPaymentRejected(payment),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'succeeded':
      case 'success':
      case 'paid':
      case 'received':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
      case 'faild':
      case 'rejected':
      case 'not_received':
      case 'not received':
      case 'cancelled':
      case 'canceled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _PaymentDecisionButton extends StatelessWidget {
  const _PaymentDecisionButton({
    required this.label,
    required this.color,
    required this.isPrimary,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
    );
    final child = isLoading
        ? SizedBox(
            width: 18.r,
            height: 18.r,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isPrimary ? Colors.white : color,
              ),
            ),
          )
        : Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: figtreeTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isPrimary ? Colors.white : color,
            ),
          );

    if (isPrimary) {
      return SizedBox(
        height: 42.h,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.cardBackground,
            disabledForegroundColor: AppColors.textSecondary,
            shape: shape,
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 42.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          disabledForegroundColor: AppColors.textSecondary,
          side: BorderSide(
            color: onPressed == null ? AppColors.cardBackground : color,
          ),
          shape: shape,
        ),
        child: child,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 96.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: figtreeTextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cleanedValue = value.trim().isEmpty ? 'N/A' : value.trim();

    return Row(
      children: [
        SizedBox(
          width: 112.w,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: figtreeTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            cleanedValue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: figtreeTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.controller});

  final AdminInstallerPaymentsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        height: 44.h,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: controller.isLoadingMore.value
              ? null
              : controller.loadMorePayments,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gradientEnd,
            side: const BorderSide(color: AppColors.gradientEnd),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: controller.isLoadingMore.value
              ? SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'Load More',
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gradientEnd,
                  ),
                ),
        ),
      ),
    );
  }
}

class _EmptyPayments extends StatelessWidget {
  const _EmptyPayments();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 34.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFEBEFF1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 42.r,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12.h),
          Text(
            'No payments found',
            style: figtreeTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'This installer has no payment records yet.',
            textAlign: TextAlign.center,
            style: figtreeTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 42.r, color: AppColors.error),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: figtreeTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 14.h),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
