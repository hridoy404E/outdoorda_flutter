import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_appbar.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/features/admin_section/job_management/controllers/job_management_details_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/job_management/models/admin_job.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/models/customer_post_bid_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/job_details_card_admin.dart';
import '../widgets/job_tracking_view_admin.dart';

class JobManagementDetailsScreen extends StatelessWidget {
  const JobManagementDetailsScreen({super.key});

  /// Get gradient colors based on job status (Figma exact)
  LinearGradient _getStatusGradient(AdminJobStatus status) {
    switch (status) {
      case AdminJobStatus.pending:
      case AdminJobStatus.receivingBids:
        return const LinearGradient(
          colors: [Color(0xFFFEA642), Color(0xFFFF6A00)],
        );
      case AdminJobStatus.completed:
        return const LinearGradient(
          colors: [
            Color(0xFF11D000), // #11d000
            Color(0xFF0C5302), // #9900ff
          ],
        );
      case AdminJobStatus.assigned:
        return const LinearGradient(
          colors: [
            Color(0xFFFFA800), // #ffa800
            Color(0xFFFF6A00), // #ff6a00
          ],
        );
      case AdminJobStatus.inProgress:
        return const LinearGradient(
          colors: [
            Color(0xFF429AFE), // #429afe
            Color(0xFF006FFF), // #006fff
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobManagementDetailsController>();

    return Scaffold(
      appBar: CustomAppBar(
        greetingText: 'Dashboard',
        userType: 'Real-time screening program management and compliance',
        loadProfileImageFromApi: true,
      ),
      body: SafeArea(
        child: Obx(() {
          final job = controller.currentJob.value;
          if (job == null) {
            return const Center(child: Text('No job data available'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Back button, job number, status badge
                  Row(
                    children: [
                      // Back button - 32px size
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        iconSize: 24.r,
                        color: Colors.black,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Get.back(),
                      ),
                      SizedBox(width: 12.w),
                      // Job number
                      Text(
                        job.jobNumber,
                        style: figtreeTextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600, // SemiBold
                          color: const Color(0xFF1E242C), // #1e242c
                        ),
                      ),
                      const Spacer(),
                      // Status badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: _getStatusGradient(job.status),
                          borderRadius: BorderRadius.circular(9999.r),
                        ),
                        child: Text(
                          job.status.displayName,
                          style: figtreeTextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600, // SemiBold
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h), // 20px gap after header

                  if (controller.shouldShowBids) ...[
                    _buildBidStatusCard(controller),
                    SizedBox(height: 16.h),
                    _buildBidsSection(controller),
                    SizedBox(height: 16.h),
                  ],

                  // Conditionally show Job Tracking for completed jobs
                  if (job.status == AdminJobStatus.completed) ...[
                    JobTrackingViewAdmin(job: job),
                    SizedBox(height: 16.h), // 32px gap after tracking
                  ],

                  // Job Details Card
                  JobDetailsCardAdmin(job: job),
                  SizedBox(height: 16.h),

                  _buildAddressDetailsCard(job),
                  SizedBox(height: 16.h), // gap before site photos
                  // Site photos and document files section
                  if (job.sitePhotos.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(24.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBE8E3), // #ebe8e3
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 24.r,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.sitePhotos,
                            style: figtreeTextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600, // SemiBold
                              color: const Color(0xFF2B4554), // #2b4554
                            ),
                          ),
                          SizedBox(height: 12.h),

                          Container(
                            height: 1.h,
                            color: const Color(0xFFC2CCD3),
                          ),
                          SizedBox(height: 12.h),

                          Column(
                            children: job.sitePhotos.asMap().entries.map((
                              entry,
                            ) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: entry.key == job.sitePhotos.length - 1
                                      ? 0
                                      : 12.h,
                                ),
                                child: _buildMediaCard(entry.value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAddressDetailsCard(AdminJob job) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE8E3),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address Details',
            style: figtreeTextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B4554),
            ),
          ),
          SizedBox(height: 12.h),
          Container(height: 1.h, color: const Color(0xFFC2CCD3)),
          SizedBox(height: 12.h),
          _buildAddressRow('Address Line 1', job.addressLine1),
          _buildAddressRow('Address Line 2', job.addressLine2),
          _buildAddressRow('City', job.city),
          _buildAddressRow('State', job.state),
          _buildAddressRow('Zip Code', job.zipCode, isLast: true),
        ],
      ),
    );
  }

  Widget _buildAddressRow(String label, String value, {bool isLast = false}) {
    final display = value.trim().isEmpty ? '-' : value.trim();
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFC2CCD3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 106.w,
              child: Text(
                label,
                style: figtreeTextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6C7787),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                display,
                style: figtreeTextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2B4554),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCard(String mediaUrl) {
    final isImage = _isImageMediaUrl(mediaUrl);

    return InkWell(
      onTap: () => _openMediaUrl(mediaUrl),
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.42),
          border: Border.all(color: const Color(0xFF6FAACC), width: 2.w),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: isImage ? _buildImageMedia(mediaUrl) : _buildFileMedia(mediaUrl),
      ),
    );
  }

  Widget _buildImageMedia(String mediaUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          child: SizedBox(
            height: 160.h,
            width: double.infinity,
            child: Image.network(
              mediaUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported_outlined),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(12.r),
          child: _buildMediaDetails(
            icon: Icons.image_outlined,
            title: _fileNameFromUrl(mediaUrl),
            subtitle: 'Image file',
          ),
        ),
      ],
    );
  }

  Widget _buildFileMedia(String mediaUrl) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 120.h),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          children: [
            Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                color: const Color(0xFF6FAACC).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                _fileIcon(mediaUrl),
                size: 30.r,
                color: const Color(0xFF2B4554),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildMediaDetails(
                icon: Icons.insert_drive_file_outlined,
                title: _fileNameFromUrl(mediaUrl),
                subtitle: '${_fileTypeLabel(mediaUrl)} - Tap to open',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaDetails({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16.r, color: const Color(0xFF6C7787)),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: figtreeTextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2B4554),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: figtreeTextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6C7787),
          ),
        ),
      ],
    );
  }

  bool _isImageMediaUrl(String url) {
    final extension = _fileExtension(url);
    return const {
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
      'heic',
      'heif',
    }.contains(extension);
  }

  IconData _fileIcon(String url) {
    switch (_fileExtension(url)) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _fileTypeLabel(String url) {
    final extension = _fileExtension(url);
    if (extension.isEmpty) return 'File';
    if (extension == 'pdf') return 'PDF document';
    if (extension == 'doc' || extension == 'docx') return 'Word document';
    return '${extension.toUpperCase()} file';
  }

  String _fileNameFromUrl(String url) {
    final path = Uri.tryParse(url)?.path ?? url;
    final slashIndex = path.lastIndexOf('/');
    final fileName = slashIndex == -1 ? path : path.substring(slashIndex + 1);
    return fileName.trim().isEmpty
        ? 'Attachment'
        : Uri.decodeComponent(fileName);
  }

  String _fileExtension(String url) {
    final fileName = _fileNameFromUrl(url);
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) return '';
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  Future<void> _openMediaUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildBidStatusCard(JobManagementDetailsController controller) {
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: _getStatusGradient(AdminJobStatus.receivingBids),
                  borderRadius: BorderRadius.circular(9999.r),
                ),
                child: Text(
                  AppStrings.receivingBids,
                  style: figtreeTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final count = controller.bids.length;
            return Text(
              'You have received $count proposal${count == 1 ? '' : 's'} from installers',
              style: figtreeTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E242C),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBidsSection(JobManagementDetailsController controller) {
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
        children: bids.map((bid) => _buildBidCard(bid, controller)).toList(),
      );
    });
  }

  Widget _buildBidCard(
    CustomerPostBidModel bid,
    JobManagementDetailsController controller,
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
          if (bid.note != null && bid.note!.trim().isNotEmpty)
            Text(
              bid.note!,
              style: figtreeTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          if (bid.price != null) ...[
            SizedBox(height: 6.h),
            Text(
              'Price: ${_formatBidPrice(bid.price!)}',
              style: figtreeTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.priceColor,
              ),
            ),
          ],
          if (bid.createdAt != null) ...[
            SizedBox(height: 6.h),
            Text(
              'Submitted: ${DateFormat('MMM d, yyyy h:mm a').format(bid.createdAt!)}',
              style: figtreeTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Obx(() {
            final isAccepting = controller.acceptingBidId.value == bid.id;
            return GestureDetector(
              onTap: isAccepting ? null : () => controller.acceptBid(bid),
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
        ],
      ),
    );
  }

  String _formatBidPrice(double price) {
    final priceInt = price.truncate();
    if (price == priceInt.toDouble()) {
      return '\$$priceInt';
    }
    return '\$${price.toStringAsFixed(2)}';
  }
}
