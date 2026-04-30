import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/services/firebase/notification_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/home/controllers/admin_home_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/job_management/controllers/job_management_details_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/settings/controllers/admin_settings_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/controllers/user_management_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/payment/controllers/admin_installer_payments_controller.dart';
import 'package:outdoorda_flutter/features/customer_section/home/help_center/controller/help_center_controller.dart';
import 'package:outdoorda_flutter/features/customer_section/home/messaging/controllers/message_list_controller.dart';
import 'package:outdoorda_flutter/features/customer_section/home/messaging/controllers/messaging_controller.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/controllers/new_service_controller.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/controllers/bid_details_controller.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/controllers/customar_home_controller.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/controllers/review_controller.dart';
import 'package:outdoorda_flutter/features/customer_section/settings/controllers/customar_setting_controller.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/create_account/controllers/create_account_controller.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/forgot_password/controllers/email_verify_controller.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/forgot_password/controllers/otp_verify_controller.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/forgot_password/controllers/reset_password_controller.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/login/controllers/login_controller.dart';
import 'package:outdoorda_flutter/features/global_section/bottom_navbar/controllers/bottom_navbar_controller.dart';
import 'package:outdoorda_flutter/features/admin_section/job_management/controllers/job_management_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/management/controllers/installer_management_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/management/controllers/installer_admin_posts_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/management/controllers/management_details_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/payment/controllers/installer_commission_payment_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/payment/controllers/installer_payment_details_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/settings/controllers/installer_setting_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/message_section/controllers/message_list_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/message_section/controllers/messaging_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.put<NotificationController>(NotificationController(), permanent: true);

    /// Authentication controllers
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);

    Get.lazyPut<CreateAccountController>(
      () => CreateAccountController(),
      fenix: true,
    );

    /// Forgot password controllers
    Get.lazyPut<EmailVerifyController>(() => EmailVerifyController());

    Get.lazyPut<OtpVerifyController>(() => OtpVerifyController());

    Get.lazyPut<ResetPasswordController>(() => ResetPasswordController());

    /// Bottom navbar controller
    Get.lazyPut<BottomNavbarController>(
      () => BottomNavbarController(),
      fenix: true,
    );

    /// Admin home controller
    Get.lazyPut<AdminHomeController>(() => AdminHomeController(), fenix: true);

    /// Service request controller
    Get.lazyPut<CustomarHomeController>(
      () => CustomarHomeController(),
      fenix: true,
    );

    /// Add service controller
    Get.lazyPut<NewServiceController>(
      () => NewServiceController(),
      fenix: true,
    );

    /// Messaging controllers
    Get.lazyPut<MessageListController>(
      () => MessageListController(),
      fenix: true,
    );

    Get.lazyPut<MessagingController>(() => MessagingController(), fenix: true);

    /// Help center controller
    Get.lazyPut<HelpCenterController>(
      () => HelpCenterController(),
      fenix: true,
    );

    /// Settings controller
    Get.lazyPut<CustomerSettingController>(
      () => CustomerSettingController(),
      fenix: true,
    );

    /// Installer management controllers
    Get.lazyPut<InstallerManagementController>(
      () => InstallerManagementController(),
      fenix: true,
    );

    Get.lazyPut<InstallerAdminPostsController>(
      () => InstallerAdminPostsController(),
      fenix: true,
    );

    Get.lazyPut<ManagementDetailsController>(
      () => ManagementDetailsController(),
      fenix: true,
    );

    /// Installer settings controller
    Get.lazyPut<InstallerSettingController>(
      () => InstallerSettingController(),
      fenix: true,
    );

    Get.lazyPut<InstallerPaymentDetailsController>(
      () => InstallerPaymentDetailsController(),
      fenix: true,
    );

    Get.lazyPut<InstallerCommissionPaymentController>(
      () => InstallerCommissionPaymentController(),
      fenix: true,
    );

    /// Admin management controllers
    Get.lazyPut<JobManagementController>(
      () => JobManagementController(),
      fenix: true,
    );

    Get.lazyPut<JobManagementDetailsController>(
      () => JobManagementDetailsController(),
      fenix: true,
    );

    /// Admin settings controller
    Get.lazyPut<AdminSettingsController>(
      () => AdminSettingsController(),
      fenix: true,
    );

    /// Admin user management controller
    Get.lazyPut<UserManagementController>(
      () => UserManagementController(),
      fenix: true,
    );

    Get.lazyPut<AdminInstallerPaymentsController>(
      () => AdminInstallerPaymentsController(),
      fenix: true,
    );

    /// Installer messaging controllers
    Get.lazyPut<InstallerMessageListController>(
      () => InstallerMessageListController(),
      fenix: true,
    );

    Get.lazyPut<InstallerMessagingController>(
      () => InstallerMessagingController(),
      fenix: true,
    );

    /// Bid details controller
    Get.lazyPut<BidDetailsController>(
      () => BidDetailsController(),
      fenix: true,
    );

    /// Review controller
    Get.lazyPut<RequestDetailsController>(
      () => RequestDetailsController(),
      fenix: true,
    );
  }
}
