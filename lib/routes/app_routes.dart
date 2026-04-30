import 'package:get/get.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/views/screens/all_requests_screen.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/views/screens/requests_details_screen.dart';
import 'package:outdoorda_flutter/features/customer_section/home/messaging/views/screens/message_list_screen.dart';
import 'package:outdoorda_flutter/features/customer_section/home/messaging/views/screens/messaging_screen.dart';
import 'package:outdoorda_flutter/features/customer_section/settings/views/screens/customar_setting_screen.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/create_account/screens/create_account_screen.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/forgot_password/screens/email_verify_screen.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/forgot_password/screens/otp_verify_screen.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/forgot_password/screens/reset_password_screen.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/login/screens/login_screen.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/login/screens/installer_payment_setup_screen.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/signup_otp/controllers/signup_otp_controller.dart';
import 'package:outdoorda_flutter/features/global_section/authentication/signup_otp/screens/signup_otp_screen.dart';
import 'package:outdoorda_flutter/features/global_section/bottom_navbar/views/screens/bottom_navbar_screen.dart';
import 'package:outdoorda_flutter/features/global_section/splash/screens/splash_screen.dart';
import 'package:outdoorda_flutter/features/admin_section/job_management/views/screens/job_management_screen.dart';
import 'package:outdoorda_flutter/features/admin_section/job_management/views/screens/job_management_details.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/payment/views/screens/admin_installer_payments_screen.dart';
import 'package:outdoorda_flutter/features/admin_section/user_management/views/screens/user_details_screen.dart';
import 'package:outdoorda_flutter/features/installer_section/management/views/screens/installer_admin_posts_screen.dart';
import 'package:outdoorda_flutter/features/installer_section/management/views/screens/installer_management_screen.dart';
import 'package:outdoorda_flutter/features/installer_section/management/views/screens/management_details_screen.dart';
import 'package:outdoorda_flutter/features/installer_section/message_section/views/screens/conversation_list_screen.dart';
import 'package:outdoorda_flutter/features/installer_section/message_section/views/screens/conversation_screen.dart';
import 'package:outdoorda_flutter/features/installer_section/payment/views/screens/installer_commission_payment_screen.dart';
import 'package:outdoorda_flutter/features/installer_section/payment/views/screens/installer_payment_details_screen.dart';

class AppRoute {
  static String splashScreen = "/splashScreen";
  static String loginScreen = "/loginScreen";
  static String createAccountScreen = "/createAccountScreen";
  static String emailVerifyScreen = "/emailVerifyScreen";
  static String otpVerifyScreen = "/otpVerifyScreen";
  static String resetPasswordScreen = "/resetPasswordScreen";
  static String installerPaymentSetupScreen = "/installerPaymentSetupScreen";
  static String bottomNavbarScreen = "/bottomNavbarScreen";
  static String signupOtpScreen = "/signupOtpScreen";
  static String messageListScreen = "/messageListScreen";
  static String messagingScreen = "/messagingScreen";
  static String allRequestsScreen = "/allRequestsScreen";
  static String requestsDetailsScreen = "/requestsDetailsScreen";
  static String customerSettingScreen = "/customerSettingScreen";
  static String installerManagementScreen = "/installerManagementScreen";
  static String installerAdminPostsScreen = "/installerAdminPostsScreen";
  static String managementDetailsScreen = "/managementDetailsScreen";
  static String adminManagementScreen = "/adminManagementScreen";
  static String adminManagementDetailsScreen = "/adminManagementDetailsScreen";
  static String adminInstallerPaymentsScreen = "/adminInstallerPaymentsScreen";
  static String adminUserDetailsScreen = "/adminUserDetailsScreen";
  static String installerConversationListScreen =
      "/installerConversationListScreen";
  static String installerConversationScreen = "/installerConversationScreen";
  static String installerPaymentDetailsScreen =
      "/installerPaymentDetailsScreen";
  static String installerCommissionPaymentScreen =
      "/installerCommissionPaymentScreen";

  static String getSplashScreen() => splashScreen;
  static String getLoginScreen() => loginScreen;
  static String getCreateAccountScreen() => createAccountScreen;
  static String getEmailVerifyScreen() => emailVerifyScreen;
  static String getOtpVerifyScreen() => otpVerifyScreen;
  static String getResetPasswordScreen() => resetPasswordScreen;
  static String getInstallerPaymentSetupScreen() => installerPaymentSetupScreen;
  static String getBottomNavbarScreen() => bottomNavbarScreen;
  static String getSignupOtpScreen() => signupOtpScreen;
  static String getMessageListScreen() => messageListScreen;
  static String getMessagingScreen() => messagingScreen;
  static String getAllRequestsScreen() => allRequestsScreen;
  static String getRequestsDetailsScreen() => requestsDetailsScreen;
  static String getCustomerSettingScreen() => customerSettingScreen;
  static String getInstallerManagementScreen() => installerManagementScreen;
  static String getInstallerAdminPostsScreen() => installerAdminPostsScreen;
  static String getManagementDetailsScreen() => managementDetailsScreen;
  static String getAdminManagementScreen() => adminManagementScreen;
  static String getAdminManagementDetailsScreen() =>
      adminManagementDetailsScreen;
  static String getAdminInstallerPaymentsScreen() =>
      adminInstallerPaymentsScreen;
  static String getAdminUserDetailsScreen() => adminUserDetailsScreen;
  static String getInstallerConversationListScreen() =>
      installerConversationListScreen;
  static String getInstallerConversationScreen() => installerConversationScreen;
  static String getInstallerPaymentDetailsScreen() =>
      installerPaymentDetailsScreen;
  static String getInstallerCommissionPaymentScreen() =>
      installerCommissionPaymentScreen;

  static List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: loginScreen, page: () => const LoginScreen()),
    GetPage(name: createAccountScreen, page: () => const CreateAccountScreen()),
    GetPage(name: emailVerifyScreen, page: () => const EmailVerifyScreen()),
    GetPage(name: otpVerifyScreen, page: () => const OtpVerifyScreen()),
    GetPage(name: resetPasswordScreen, page: () => const ResetPasswordScreen()),
    GetPage(
      name: installerPaymentSetupScreen,
      page: () => const InstallerPaymentSetupScreen(),
    ),
    GetPage(
      name: signupOtpScreen,
      page: () => const SignupOtpScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut<SignupOtpController>(
          () => SignupOtpController(),
          fenix: true,
        ),
      ),
    ),
    GetPage(name: bottomNavbarScreen, page: () => const BottomNavbarScreen()),
    GetPage(name: messageListScreen, page: () => const MessageListScreen()),
    GetPage(name: messagingScreen, page: () => const MessagingScreen()),
    GetPage(name: allRequestsScreen, page: () => const AllRequestsScreen()),
    GetPage(
      name: requestsDetailsScreen,
      page: () => const RequestsDetailsScreen(),
    ),
    GetPage(
      name: customerSettingScreen,
      page: () => const CustomerSettingScreen(),
    ),
    GetPage(
      name: installerManagementScreen,
      page: () => const InstallerManagementScreen(),
    ),
    GetPage(
      name: installerAdminPostsScreen,
      page: () => const InstallerAdminPostsScreen(),
    ),
    GetPage(
      name: managementDetailsScreen,
      page: () => const ManagementDetailsScreen(),
    ),
    GetPage(
      name: adminManagementScreen,
      page: () => const JobManagementScreen(),
    ),
    GetPage(
      name: adminManagementDetailsScreen,
      page: () => const JobManagementDetailsScreen(),
    ),
    GetPage(
      name: adminInstallerPaymentsScreen,
      page: () => const AdminInstallerPaymentsScreen(),
    ),
    GetPage(
      name: adminUserDetailsScreen,
      page: () => const UserDetailsScreen(),
    ),
    GetPage(
      name: installerConversationListScreen,
      page: () => const InstallerConversationListScreen(),
    ),
    GetPage(
      name: installerConversationScreen,
      page: () => const InstallerConversationScreen(),
    ),
    GetPage(
      name: installerPaymentDetailsScreen,
      page: () => const InstallerPaymentDetailsScreen(),
    ),
    GetPage(
      name: installerCommissionPaymentScreen,
      page: () => const InstallerCommissionPaymentScreen(),
    ),
  ];
}
