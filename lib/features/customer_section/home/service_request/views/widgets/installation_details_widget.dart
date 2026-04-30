import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import '../../models/service_request_model.dart';

class InstallationDetailsWidget extends StatelessWidget {
  const InstallationDetailsWidget({super.key, required this.service});

  final ServiceRequest service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
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
          Text(
            AppStrings.installationDetails,
            style: figtreeTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),

          // Two-column layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Type
                    Text(
                      '${AppStrings.serviceType}:',
                      style: figtreeTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      service.serviceType ?? AppStrings.doorInstallation,
                      style: figtreeTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Pet
                    Text(
                      '${AppStrings.pet}:',
                      style: figtreeTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      service.petName ?? 'Max (Dog)',
                      style: figtreeTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 12.w),

              // Right column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pet Door
                    Text(
                      AppStrings.petDoor,
                      style: figtreeTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      AppStrings.patioPanel,
                      style: figtreeTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Price Quote
                    Text(
                      AppStrings.priceQuote,
                      style: figtreeTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF6FAACC), Color(0xFF395C70)],
                      ).createShader(bounds),
                      child: Text(
                        service.priceQuote ?? AppStrings.pending,
                        style: figtreeTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Divider
          Container(height: 1, color: const Color(0xFFD9D9D9)),

          SizedBox(height: 12.h),

          // Address
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.address}:',
                style: figtreeTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 24.r,
                    color: AppColors.textDark,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      service.address,
                      style: figtreeTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
