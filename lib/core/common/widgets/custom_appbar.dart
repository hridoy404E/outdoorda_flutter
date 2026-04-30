import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/services/user_profile_api_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/core/utils/constants/image_path.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';

/// Reusable custom app bar for the application
/// Displays greeting text, user badge, and profile image
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.greetingText,
    required this.userType,
    this.profileImageUrl,
    this.onProfileTap,
    this.loadProfileImageFromApi = false,
  });

  final String greetingText;
  final String userType;
  final String? profileImageUrl;
  final VoidCallback? onProfileTap;
  final bool loadProfileImageFromApi;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(120.h);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final UserProfileApiService _userProfileApiService = UserProfileApiService();
  String? _resolvedProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _resolvedProfileImageUrl = _cleanProfileUrl(widget.profileImageUrl);
    _maybeLoadProfileImage();
  }

  @override
  void didUpdateWidget(covariant CustomAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final updated = _cleanProfileUrl(widget.profileImageUrl);
    if (updated != _resolvedProfileImageUrl) {
      setState(() => _resolvedProfileImageUrl = updated);
    }
    if (_resolvedProfileImageUrl == null) {
      _maybeLoadProfileImage();
    }
  }

  Future<void> _maybeLoadProfileImage() async {
    if (!widget.loadProfileImageFromApi) return;
    if (_resolvedProfileImageUrl != null) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) return;

    try {
      final profile = await _userProfileApiService.fetchCurrentUser(
        authorization: authorization,
      );
      final imageUrl = _cleanProfileUrl(profile.photo);
      if (!mounted || imageUrl == null) return;
      setState(() => _resolvedProfileImageUrl = imageUrl);
    } catch (error) {
      AppLoggerHelper.warning('CustomAppBar profile image load failed: $error');
    }
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return null;

    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }

  String? _cleanProfileUrl(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty || raw.toLowerCase() == 'null') return null;
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = _resolvedProfileImageUrl;
    return Container(
      height: widget.preferredSize.height,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: const BoxDecoration(color: AppColors.bg),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Logo section - SVG from Figma
            Image.asset(ImagePath.appbarlogo, width: 42.w, height: 29.h),
            SizedBox(width: 14.w),

            // Greeting and user type section
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.greetingText,
                    style: figtreeTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackText,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    widget.userType,
                    style: figtreeTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.blackTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Profile and badge section
            GestureDetector(
              onTap: widget.onProfileTap,
              child: Container(
                width: 38.w,
                height: 38.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neutral300,
                  image: profileImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(profileImageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profileImageUrl == null
                    ? Icon(Icons.person, size: 18.r, color: AppColors.neutral25)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
