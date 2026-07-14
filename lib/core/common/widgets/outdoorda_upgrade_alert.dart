import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:upgrader/upgrader.dart';

/// A custom upgrader that forces updates when the major version changes,
/// while keeping minor/patch updates optional and dismissible.
class OutdoordaUpgrader extends Upgrader {
  OutdoordaUpgrader({
    super.debugDisplayAlways,
    super.debugLogging,
  });

  @override
  bool blocked() {
    // If the base Upgrader already blocked it, keep it blocked
    if (super.blocked()) return true;

    final storeVersion = state.versionInfo?.appStoreVersion;
    final installedVersion = state.versionInfo?.installedVersion;

    if (storeVersion != null && installedVersion != null) {
      // Force update if the major version is higher (e.g., from 1.x.x to 2.x.x)
      if (storeVersion.major > installedVersion.major) {
        return true;
      }
    }
    return false;
  }
}

/// Custom UpgradeAlert widget that returns our premium designed dialog.
class OutdoordaUpgradeAlert extends UpgradeAlert {
  OutdoordaUpgradeAlert({
    super.key,
    super.upgrader,
    super.barrierDismissible,
    super.dialogStyle,
    super.onIgnore,
    super.onLater,
    super.onUpdate,
    super.shouldPopScope,
    super.showIgnore,
    super.showLater,
    super.showReleaseNotes,
    super.cupertinoButtonTextStyle,
    super.dialogKey,
    super.navigatorKey,
    super.child,
  });

  @override
  UpgradeAlertState createState() => _OutdoordaUpgradeAlertState();
}

class _OutdoordaUpgradeAlertState extends UpgradeAlertState {
  @override
  Widget alertDialog(
    Key? key,
    String title,
    String message,
    String? releaseNotes,
    BuildContext context,
    bool cupertino,
    UpgraderMessages messages,
  ) {
    final isBlocked = widget.upgrader.blocked();
    final showIgnore = isBlocked ? false : widget.showIgnore;
    final showLater = isBlocked ? false : widget.showLater;

    return Dialog(
      key: key,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      elevation: 6,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Icon Badge with brand color gradient
              Container(
                width: 60.r,
                height: 60.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF395C70),
                      Color(0xFF2E4B5B),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.system_update_alt_rounded,
                  color: Colors.white,
                  size: 28.r,
                ),
              ),
              SizedBox(height: 20.h),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B), // slate 800
                ),
              ),
              SizedBox(height: 10.h),

              // Message description
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 13.sp,
                  height: 1.45,
                  color: const Color(0xFF64748B), // slate 500
                ),
              ),

              // Release Notes block (if any)
              if (releaseNotes != null && widget.showReleaseNotes) ...[
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxHeight: 110.h),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC), // slate 50
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)), // slate 200
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          messages.message(UpgraderMessage.releaseNotes) ?? 'Release Notes:',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF334155), // slate 700
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          releaseNotes,
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 11.sp,
                            height: 1.35,
                            color: const Color(0xFF475569), // slate 600
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 24.h),

              // Action Buttons Layout
              Column(
                children: [
                  // 1. Update Now (Primary)
                  SizedBox(
                    width: double.infinity,
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: () => onUserUpdated(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF395C70),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        messages.message(UpgraderMessage.buttonTitleUpdate) ?? 'Update Now',
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // 2. Later (Secondary outlines)
                  if (showLater) ...[
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: double.infinity,
                      height: 46.h,
                      child: OutlinedButton(
                        onPressed: () => onUserLater(context, true),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)), // slate 300
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          messages.message(UpgraderMessage.buttonTitleLater) ?? 'Later',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // 3. Ignore (Tertiary text link)
                  if (showIgnore) ...[
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: () => onUserIgnored(context, true),
                      child: Text(
                        messages.message(UpgraderMessage.buttonTitleIgnore) ?? 'Ignore this version',
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 12.sp,
                          color: const Color(0xFF94A3B8), // slate 400
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
