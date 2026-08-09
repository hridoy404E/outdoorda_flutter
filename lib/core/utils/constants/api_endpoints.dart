class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.pdusainstall.com';

  static const String login = '$baseUrl/auth/login';
  static const String verifyToken = '$baseUrl/auth/verify-token';
  static const String resetPassword = '$baseUrl/auth/reset_password';
  static const String forgotPassword = '$baseUrl/auth/forgot_password';
  static const String sendOtp = '$baseUrl/auth/send_otp';
  static const String verifyOtp = '$baseUrl/auth/verify_otp';
  static const String signup = '$baseUrl/auth/signup';
  static const String users = '$baseUrl/user/users/';
  static const String userSuspend = '$baseUrl/user/users/suspend';
  static const String currentUser = '$baseUrl/user/users/me';
  static const String deleteCurrentUser = '$baseUrl/user/users/me/delete';
  static const String updateCurrentUserProfile =
      '$baseUrl/user/users/me/update-profile';
  static const String toggleTwoFactor = '$baseUrl/user/users/toggle-two-factor';
  static const String serviceAreas = '$baseUrl/installer/service-areas';
  static const String installerServiceAreas =
      '$baseUrl/installer/installer/service-areas';
  static const String installerAvailability =
      '$baseUrl/installer/installer-availability/';
  static const String installerAvailabilityGet =
      '$baseUrl/installer/installer-availability-get/';
  static const String installerEarnings =
      '$baseUrl/installer/installer/earnings/';
  static const String adminRecentJobs = '$baseUrl/admin/recent-jobs/';
  static const String adminRecentBids = '$baseUrl/admin/recent-bids';
  static const String adminPostStats = '$baseUrl/admin/post-stats';
  static const String adminJobManagementSettings =
      '$baseUrl/admin/job-management-settings';
  static const String adminPaymentSettings = '$baseUrl/admin/payment-settings/';
  static const String adminServiceAreas = '$baseUrl/admin/service-areas';
  static const String adminInstallers = '$baseUrl/admin/installers/';
  static const String adminPostsAdmin = '$baseUrl/admin/posts-admin/';
  static const String createServiceRequest = '$baseUrl/customer/posts/';
  static const String customerPosts = '$baseUrl/customer/posts/';
  static const String customerPostBids = '$baseUrl/customer/posts-bids/';
  static const String customerBid = '$baseUrl/customer/bid/';
  static const String customerReview = '$baseUrl/customer/review';
  static const String customerPets = '$baseUrl/customer/pets/';
  static const String installerRatings = '$baseUrl/installer/installer-ratings';
  static const String createPaymentIntent = '$baseUrl/payment/payments/create';
  static const String cashPayment = '$baseUrl/payment/cash-payment/';
  static const String paymentAccountIsReady =
      '$baseUrl/payment/account-is-ready';
  static const String installerStripeCreateAccount =
      '$baseUrl/payment/installer/stripe/create-account';
  static const String installerStripeOnboardingLink =
      '$baseUrl/payment/installer/stripe/onboarding-link';
  static const String stripeManualWebhook =
      '$baseUrl/payment/stripe/manual-webhook';
  static const String installerPayments =
      '$baseUrl/payment/installer/payments/';
  static const String saveFcmToken = '$baseUrl/communications/save_token/';
}
