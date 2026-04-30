import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/features/installer_section/management/controllers/management_details_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/management/models/management_job.dart';
import 'package:outdoorda_flutter/features/installer_section/management/views/widgets/job_progress_tracking_widget.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/controllers/installer_setting_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/views/widgets/installer_profile_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/common/widgets/custom_appbar.dart';
import '../widgets/job_details_card.dart';

/// Management details screen - 100% Figma pixel-perfect implementation
/// Background: #EBE8E3, Padding 10w/20h starting 124h from top
class ManagementDetailsScreen extends StatelessWidget {
  const ManagementDetailsScreen({super.key});

  /// Get gradient colors based on job status (Figma exact)
  LinearGradient _getStatusGradient(JobStatus status) {
    switch (status) {
      case JobStatus.completed:
        return const LinearGradient(
          colors: [
            Color(0xFF11D000), // #11d000
            Color(0xFF0C5302), // #0c5302
          ],
        );
      case JobStatus.assigned:
        return const LinearGradient(
          colors: [
            Color(0xFFFEA642), // #fea642
            Color(0xFFFF6A00), // #ff6a00
          ],
        );
      case JobStatus.inProgress:
        return const LinearGradient(
          colors: [
            Color(0xFF429AFE), // #429afe
            Color(0xFF006FFF), // #006fff
          ],
        );
    }
  }

  LinearGradient _getStatusGradientForJob(ManagementJob job) {
    final label = job.statusLabel.trim().toLowerCase();
    if (label == 'pending' ||
        label == 'receiving bids' ||
        label == 'receiving_bids') {
      return const LinearGradient(
        colors: [Color(0xFFFEA642), Color(0xFFFF6A00)],
      );
    }

    return _getStatusGradient(job.status);
  }

  String _statusText(ManagementJob job) {
    return job.statusLabel.trim().isNotEmpty
        ? job.statusLabel
        : job.status.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManagementDetailsController>();
    final settingController = Get.find<InstallerSettingController>();
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Obx(
      () => Scaffold(
        key: scaffoldKey,
        appBar: CustomAppBar(
          greetingText: 'Dashboard',
          userType: 'Real-time screening program management and compliance',
          profileImageUrl: settingController.profileImageUrl.value.isEmpty
              ? null
              : settingController.profileImageUrl.value,
          onProfileTap: () {
            settingController.refreshUserProfileForDrawer();
            scaffoldKey.currentState?.openEndDrawer();
          },
        ),
        endDrawer: InstallerProfileDrawer(controller: settingController),
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
                            gradient: _getStatusGradientForJob(job),
                            borderRadius: BorderRadius.circular(9999.r),
                          ),
                          child: Text(
                            _statusText(job),
                            style: figtreeTextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600, // SemiBold
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h), // 16px gap after header
                    // New posts can either be accepted directly or bid on.
                    // Assigned posts use progress tracking.
                    if (!job.isAssignedPost &&
                        job.status == JobStatus.inProgress)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: controller.isAcceptingPost.value
                                  ? null
                                  : controller.acceptCurrentPost,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF395C70), // #395c70
                                      Color(0xFF2B4554), // #2b4554
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: Text(
                                    controller.isAcceptingPost.value
                                        ? 'Accepting...'
                                        : 'Accept Post',
                                    style: figtreeTextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: controller.isAcceptingPost.value
                                  ? null
                                  : controller.showAdjustBidDialog,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6FAACC), // #6faacc
                                      Color(0xFF395C70), // #395c70
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: Text(
                                    'Adjust Your Bid',
                                    style: figtreeTextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      // Job Progress Tracking Card for Assigned/Completed
                      JobProgressTrackingWidget(
                        controller: controller,
                        job: job,
                      ),
                    SizedBox(height: 16.h), // 16px gap after card
                    // Job Details Card
                    JobDetailsCard(job: job),
                    SizedBox(height: 16.h),
                    _buildAddressDetailsCard(job),
                    SizedBox(height: 16.h), // 16px gap before site photos
                    // Site photos and document files section
                    if (job.sitePhotos.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(16.r),
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
                                    bottom:
                                        entry.key == job.sitePhotos.length - 1
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

                    SizedBox(height: 80.h), // Bottom padding
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAddressDetailsCard(ManagementJob job) {
    return Container(
      padding: EdgeInsets.all(16.r),
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
          _buildAddressRow('Zip Code', job.zipCode),
          _buildAddressRow('Country', job.country, isLast: true),
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
}
