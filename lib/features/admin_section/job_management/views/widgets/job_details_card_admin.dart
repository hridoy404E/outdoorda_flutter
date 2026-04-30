import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/common/styles/global_text_style.dart';
import '../../models/admin_job.dart';

class JobDetailsCardAdmin extends StatelessWidget {
  const JobDetailsCardAdmin({super.key, required this.job});

  final AdminJob? job;

  @override
  Widget build(BuildContext context) {
    final totalPrice = job?.adminEstimatedPrice ?? 0;
    final adminCommission = totalPrice * 0.20;
    final installerPrice = totalPrice - adminCommission;
    final jobNotes = job?.jobNotes.trim() ?? '';
    final shortLocation = _shortLocation(job);
    final fullAddress = _fullAddress(job);
    final petType = job?.petType.trim() ?? '';
    final petSize = job?.petSize.trim() ?? '';
    final petName = job?.petName.trim() ?? '';

    return Container(
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
          // "Job Details" title
          Text(
            'Job Details',
            style: figtreeTextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 12.h),

          // Divider
          Container(
            height: 1.h,
            color: const Color(0xFFC2CCD3), // Divider
          ),
          SizedBox(height: 12.h),

          // Location section
          Text(
            'Location:',
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400, // Regular
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            shortLocation,
            style: figtreeTextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 16.h),

          // Divider
          Container(height: 1.h, color: const Color(0xFFC2CCD3)),
          SizedBox(height: 16.h),

          // Pet Door section
          Text(
            'Pet Door:',
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400, // Regular
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _petDoorTitle(job),
            style: figtreeTextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _petDoorSubtitle(job),
            style: figtreeTextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400, // Regular
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 16.h),

          if (petName.isNotEmpty ||
              petType.isNotEmpty ||
              petSize.isNotEmpty) ...[
            Text(
              'Pet Details:',
              style: figtreeTextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF2B4554),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              [
                if (petName.isNotEmpty) 'Name: $petName',
                if (petType.isNotEmpty) 'Type: $petType',
                if (petSize.isNotEmpty) 'Size: $petSize',
              ].join(' | '),
              style: figtreeTextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2B4554),
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Installation Type section
          Text(
            'Installation Type:',
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400, // Regular
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            job?.installationType ?? '',
            style: figtreeTextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 16.h),

          // Divider
          Container(height: 1.h, color: const Color(0xFFC2CCD3)),
          SizedBox(height: 16.h),

          // Total Price
          Text(
            'Total Price:',
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400, // Regular
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _formatCurrency(totalPrice),
            style: figtreeTextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Installer Price:',
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400, // Regular
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _formatCurrency(installerPrice),
            style: figtreeTextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Admin Commission (20%):',
            style: figtreeTextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400, // Regular
              color: const Color(0xFF2B4554), // #2b4554
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _formatCurrency(adminCommission),
            style: figtreeTextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600, // SemiBold
              color: const Color(0xFF609CBF),
            ),
          ),
          SizedBox(height: 16.h),

          // Divider
          Container(height: 1.h, color: const Color(0xFFC2CCD3)),
          SizedBox(height: 16.h),

          // Job Notes section
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Job Notes: ',
                  style: figtreeTextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600, // SemiBold
                    color: const Color(0xFF2B4554), // #2b4554
                  ),
                ),
                TextSpan(
                  text: jobNotes.isNotEmpty ? jobNotes : 'No job notes',
                  style: figtreeTextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400, // Regular
                    color: const Color(0xFF2B4554), // #2b4554
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value == value.truncateToDouble()) {
      return '\$${value.toStringAsFixed(0)}';
    }
    return '\$${value.toStringAsFixed(2)}';
  }

  String _petDoorTitle(AdminJob? job) {
    if (job == null) return 'Pet Door';
    final petName = job.petName.trim();
    final petType = job.petType.trim();
    final base = job.petDoorDescription.trim();
    if (base.isNotEmpty && base != '-') return base;
    if (petName.isNotEmpty && petType.isNotEmpty) return '$petName ($petType)';
    if (petName.isNotEmpty) return petName;
    if (petType.isNotEmpty) return petType;
    return 'Pet Door';
  }

  String _petDoorSubtitle(AdminJob? job) {
    if (job == null) return '(Model: XL2000)';
    final model = job.petDoorModel.trim().isNotEmpty
        ? job.petDoorModel
        : 'XL2000';
    final petSize = job.petSize.trim();
    if (petSize.isNotEmpty) return '(Model: $model)  •  Size: $petSize';
    return '(Model: $model)';
  }

  String _fullAddress(AdminJob? job) {
    if (job == null) return '';
    final parts = <String>[
      job.addressLine1.trim(),
      job.addressLine2.trim(),
      job.city.trim(),
      job.state.trim(),
      job.zipCode.trim(),
      job.country.trim(),
    ].where((e) => e.isNotEmpty).toList();
    return parts.join(', ');
  }

  String _shortLocation(AdminJob? job) {
    if (job == null) return '-';

    final parts = <String>[
      job.city.trim(),
      job.state.trim(),
      job.country.trim(),
    ].where((e) => e.isNotEmpty).toList();

    if (parts.isNotEmpty) return parts.join(', ');

    final line1 = job.addressLine1.trim();
    if (line1.isNotEmpty) return line1;

    final fallback = job.location.trim();
    if (fallback.isNotEmpty) return fallback;
    return '-';
  }
}
