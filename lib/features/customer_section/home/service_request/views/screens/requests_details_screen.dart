import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_appbar.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import '../../controllers/bid_details_controller.dart';
import '../../controllers/customar_home_controller.dart';
import '../../models/customer_post_bid_model.dart';
import '../../models/service_request_model.dart';
import '../widgets/installation_details_widget.dart';
import '../widgets/job_tracking_view_customer.dart';
import '../widgets/proposal_card_widget.dart';
import '../widgets/status_badge_widget.dart';

/// Request Details Screen - Shows detailed information about a service request
/// Matches Figma design (node-id: 1-6077)
/// Conditional rendering based on request status
class RequestsDetailsScreen extends StatefulWidget {
  const RequestsDetailsScreen({super.key});

  @override
  State<RequestsDetailsScreen> createState() => _RequestsDetailsScreenState();
}

class _RequestsDetailsScreenState extends State<RequestsDetailsScreen> {
  late ServiceRequest _service;
  late BidDetailsController _bidController;
  late CustomarHomeController _homeController;

  bool get _showProposals =>
      _service.status == AppStrings.receivingBids ||
      _service.status == AppStrings.installerAssigned ||
      _service.status == AppStrings.inProgress;

  bool get _showBids =>
      _service.status == AppStrings.receivingBids ||
      _service.status == AppStrings.pending;

  bool get _isCompleted => _service.status == AppStrings.completed;

  bool get _showInstallerContact =>
      _service.status == AppStrings.installerAssigned ||
      _service.status == AppStrings.inProgress ||
      _service.status == AppStrings.completed;

  @override
  void initState() {
    super.initState();
    _service = Get.arguments as ServiceRequest;
    _bidController = Get.find<BidDetailsController>();
    _homeController = Get.find<CustomarHomeController>();

    if (_showBids) {
      _bidController.loadBids(_service.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const CustomAppBar(
        greetingText: AppStrings.goodMorning,
        userType: AppStrings.customer,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          SizedBox(height: 16.h),

          // Request Details title
          Text(
            AppStrings.requestDetails,
            style: figtreeTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 16.h),

          // Status card with proposals info
          _buildStatusCard(_service, _bidController),
          SizedBox(height: 20.h),

          if (_showInstallerContact) ...[
            _buildInstallerContactSection(),
            SizedBox(height: 20.h),
          ],

          if (_showBids) _buildBidsSection(_service, _bidController),
          if (_showBids) SizedBox(height: 20.h),

          // Proposals list (for Receiving Bids and Installer Assigned)
          if (_showProposals && _service.proposals != null)
            ..._service.proposals!.map(
              (proposal) => ProposalCardWidget(
                proposal: proposal,
                status: _service.status,
              ),
            ),

          // Job Tracking View (only for Completed status)
          if (_isCompleted) ...[
            JobTrackingViewCustomer(service: _service),
            SizedBox(height: 16.h),
          ],

          // Installation Details section
          InstallationDetailsWidget(service: _service),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildInstallerContactSection() {
    final installerId = _service.installerName.trim();
    final hasInstallerId =
        installerId.isNotEmpty && installerId.toLowerCase() != 'installer';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasInstallerId
                  ? '${AppStrings.assignedInstaller}: $installerId'
                  : '${AppStrings.assignedInstaller}: -',
              style: figtreeTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: hasInstallerId
                ? () => _bidController.startChatWithInstallerId(
                    installerId: installerId,
                  )
                : null,
            child: Container(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: hasInstallerId
                      ? AppColors.gradientStart
                      : AppColors.borderColor,
                ),
              ),
              child: Center(
                child: Text(
                  AppStrings.message,
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: hasInstallerId
                        ? AppColors.gradientStart
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAcceptBidTap(
    CustomerPostBidModel bid,
    BidDetailsController controller,
  ) async {
    final isSuccess = await controller.acceptBid(
      bidId: bid.id,
      postId: _service.id,
    );
    if (!mounted || !isSuccess) return;

    await _homeController.refreshCustomerHistory();
    final updatedService = _homeController.findServiceById(_service.id);
    if (!mounted || updatedService == null) return;

    setState(() {
      _service = updatedService;
    });
  }

  /// Build status card showing request status and proposals info
  Widget _buildStatusCard(
    ServiceRequest service,
    BidDetailsController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: const Border(
          left: BorderSide(color: Color(0xFFFEA642), width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.status,
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              StatusBadgeWidget(status: service.status),
            ],
          ),
          if (service.status == AppStrings.receivingBids) ...[
            SizedBox(height: 12.h),

            SizedBox(height: 4.h),
            Obx(() {
              final count = controller.bids.length;
              return Text(
                'Your Have receive $count Proposals From Indtallers',
                style: figtreeTextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E242C),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildBidsSection(
    ServiceRequest service,
    BidDetailsController controller,
  ) {
    return Obx(() {
      if (controller.isFetchingBids.value) {
        return Container(
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Center(
            child: Text(
              AppStrings.loadingBids,
              style: figtreeTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ),
        );
      }

      final bids = controller.bids;
      if (bids.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Text(
            AppStrings.noBidsYet,
            style: figtreeTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          ...bids.map((bid) => _buildBidCard(bid, controller)),
        ],
      );
    });
  }

  Widget _buildBidCard(
    CustomerPostBidModel bid,
    BidDetailsController controller,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Installer: ',
                style: figtreeTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: Text(
                  bid.installerId,
                  style: figtreeTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Text(
                bid.status,
                style: figtreeTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (bid.note != null)
            Text(
              bid.note!,
              style: figtreeTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          if (bid.price != null)
            Text(
              'Price: ${_formatBidPrice(bid.price!)}',
              style: figtreeTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.priceColor,
              ),
            ),
          if (bid.createdAt != null)
            Text(
              'Submitted: ${DateFormat('MMM d, yyyy h:mm a').format(bid.createdAt!)}',
              style: figtreeTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Ink(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.gradientStart,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8.r),
                      onTap: () => controller.startChatFromBid(bid),
                      child: Center(
                        child: Text(
                          AppStrings.message,
                          style: figtreeTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gradientStart,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Obx(() {
                  final isAccepting = controller.acceptingBidId.value == bid.id;
                  return GestureDetector(
                    onTap: isAccepting
                        ? null
                        : () => _onAcceptBidTap(bid, controller),
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF6FAACC), Color(0xFF395C70)],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: isAccepting
                            ? SizedBox(
                                width: 18.w,
                                height: 18.h,
                                child: const CircularProgressIndicator(
                                  color: AppColors.neutral25,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                AppStrings.acceptOffer,
                                style: figtreeTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.neutral25,
                                ),
                              ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatBidPrice(double price) {
    final priceInt = price.truncate();
    if (price == priceInt) {
      return '\$$priceInt';
    }
    return '\$${price.toStringAsFixed(2)}';
  }
}
