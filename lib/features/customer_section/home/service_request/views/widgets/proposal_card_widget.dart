import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';

import '../../models/proposal_model.dart';

class ProposalCardWidget extends StatelessWidget {
  const ProposalCardWidget({
    super.key,
    required this.proposal,
    required this.status,
  });

  final Proposal proposal;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: const Border(
          left: BorderSide(color: Color(0xFF6FAACC), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Installer info and price
          Row(
            children: [
              // Installer profile image
              Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(proposal.installerImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 4.w),

              // Name and rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proposal.installerName,
                      style: figtreeTextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E242C),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 18.r,
                          color: const Color(0xFFFBBC05),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${proposal.rating} (${proposal.reviewCount} ${AppStrings.reviews})',
                          style: figtreeTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6FAACC), Color(0xFF395C70)],
                ).createShader(bounds),
                child: Text(
                  proposal.price,
                  style: figtreeTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Divider
          Container(height: 1, color: const Color(0xFFD9D9D9)),

          SizedBox(height: 12.h),

          // Action buttons
          Row(
            children: [
              // Chat button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    AppLoggerHelper.debug(
                      'Chat button tapped for ${proposal.installerName}',
                    );
                  },
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFF4D7D99),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        AppStrings.message,
                        style: figtreeTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4D7D99),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Accept Offer button (only for Receiving Bids status)
              if (status == AppStrings.receivingBids) ...[
                SizedBox(width: 16.w),
                Expanded(
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          AppLoggerHelper.debug(
                            'Accept Offer tapped for ${proposal.installerName}',
                          );
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Center(
                          child: Text(
                            AppStrings.acceptOffer,
                            style: figtreeTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.neutral25,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
