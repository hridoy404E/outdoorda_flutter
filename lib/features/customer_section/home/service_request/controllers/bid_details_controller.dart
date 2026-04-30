import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:outdoorda_flutter/core/services/payments/payment_settings_api_service.dart';
import 'package:outdoorda_flutter/core/services/payments/stripe_payment_service.dart';
import 'package:outdoorda_flutter/core/services/communications/chat_session_api_service.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/services/user_profile_api_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/helpers/auth_token_helper.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/customer_section/home/messaging/models/message.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/models/customer_post_bid_model.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/services/customer_payment_api_service.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/services/customer_post_bids_api_service.dart';
import 'package:outdoorda_flutter/routes/app_routes.dart';

class BidDetailsController extends GetxController {
  final CustomerPostBidsApiService _bidsApiService =
      CustomerPostBidsApiService();
  final CustomerPaymentApiService _paymentApiService =
      CustomerPaymentApiService();
  final PaymentSettingsApiService _paymentSettingsApiService =
      PaymentSettingsApiService();
  final StripePaymentService _stripePaymentService = StripePaymentService();
  final UserProfileApiService _userProfileApiService = UserProfileApiService();
  final ChatSessionApiService _chatSessionApiService = ChatSessionApiService();

  final RxList<CustomerPostBidModel> bids = <CustomerPostBidModel>[].obs;
  final RxBool isFetchingBids = false.obs;
  final RxString acceptingBidId = ''.obs;
  String? _loadedPostId;

  Future<void> loadBids(String postId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _loadedPostId == postId && bids.isNotEmpty) return;

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Cannot load bids without authorization');
      return;
    }

    _loadedPostId = postId;
    isFetchingBids.value = true;
    try {
      final fetchedBids = await _bidsApiService.fetchBids(
        postId: postId,
        authorization: authorization,
      );
      bids.assignAll(fetchedBids);
    } catch (error) {
      AppLoggerHelper.error('Failed to fetch bids for $postId', error);
    } finally {
      isFetchingBids.value = false;
    }
  }

  Future<bool> acceptBid({
    required String bidId,
    required String postId,
  }) async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return false;
    }

    try {
      acceptingBidId.value = bidId;
      EasyLoading.show(status: 'Accepting offer...');
      await _bidsApiService.acceptBid(
        bidId: bidId,
        authorization: authorization,
      );
      await loadBids(postId, forceRefresh: true);
      EasyLoading.dismiss();
      EasyLoading.showSuccess(AppStrings.offerAcceptedSuccess);
      return true;
    } catch (error) {
      AppLoggerHelper.error('Failed to accept bid $bidId', error);
      EasyLoading.dismiss();
      EasyLoading.showError(AppStrings.offerAcceptError);
      return false;
    } finally {
      acceptingBidId.value = '';
    }
  }

  Future<bool> payWithStripeForPost({required String postId}) async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return false;
    }

    try {
      EasyLoading.show(status: AppStrings.preparingPayment);

      final clientSecret = await _paymentApiService.createPaymentIntent(
        postId: postId,
        authorization: authorization,
      );

      await _stripePaymentService.payWithPaymentSheet(
        clientSecret: clientSecret,
      );

      EasyLoading.dismiss();
      return true;
    } on PaymentCancelledException {
      EasyLoading.dismiss();
      EasyLoading.showInfo(AppStrings.paymentCancelled);
      return false;
    } on StripeException catch (error) {
      AppLoggerHelper.error('Stripe payment failed for post $postId', error);
      EasyLoading.dismiss();
      EasyLoading.showError(AppStrings.paymentFailed);
      return false;
    } catch (error) {
      AppLoggerHelper.error(
        'Failed to process stripe payment for $postId',
        error,
      );
      EasyLoading.dismiss();
      EasyLoading.showError(AppStrings.paymentFailed);
      return false;
    }
  }

  Future<bool> payWithCashForPost({required String postId}) async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return false;
    }

    try {
      EasyLoading.show(status: 'Preparing cash payment...');

      await _paymentApiService.createCashPayment(
        postId: postId,
        authorization: authorization,
      );

      EasyLoading.dismiss();
      return true;
    } catch (error) {
      AppLoggerHelper.error(
        'Failed to process cash payment for $postId',
        error,
      );
      EasyLoading.dismiss();
      EasyLoading.showError('Cash payment failed');
      return false;
    }
  }

  Future<bool> isStripePaymentEnabledForCompletion() async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning(
        'Cannot check Stripe payment setting without authorization',
      );
      return false;
    }

    try {
      final settings = await _paymentSettingsApiService.fetchPaymentSettings(
        authorization: authorization,
      );
      AppLoggerHelper.info(
        'Stripe payment setting fetched for completion: ${settings.status}',
      );
      return settings.status;
    } catch (error) {
      AppLoggerHelper.error('Failed to fetch Stripe payment setting', error);
      return false;
    }
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken;
    if (token == null || token.isEmpty) return null;
    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }

  Future<void> startChatFromBid(CustomerPostBidModel bid) async {
    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Cannot start chat without authorization');
      return;
    }

    final customerId = await _resolveCurrentUserId(authorization);
    if (customerId == null || customerId.isEmpty) {
      AppLoggerHelper.warning('Cannot start chat without customer id');
      return;
    }

    final started = await _chatSessionApiService.startChat(
      authorization: authorization,
      fromType: 'customer',
      fromId: customerId,
      toType: 'installer',
      toId: bid.installerId,
    );

    if (!started) {
      AppLoggerHelper.warning('Failed to start chat with ${bid.installerId}');
      return;
    }

    final conversation = Conversation(
      id: '${customerId}_${bid.installerId}',
      userId: bid.installerId,
      userName: bid.installerId,
      userAvatar: '',
      userType: 'installer',
      lastMessage: bid.note ?? '',
      lastMessageTime: bid.createdAt ?? DateTime.now(),
    );

    Get.toNamed(AppRoute.getMessagingScreen(), arguments: conversation);
  }

  Future<void> startChatWithInstallerId({
    required String installerId,
    String? lastMessage,
    DateTime? lastMessageTime,
  }) async {
    final cleanedInstallerId = installerId.trim();
    if (cleanedInstallerId.isEmpty) {
      AppLoggerHelper.warning('Cannot start chat without installer id');
      return;
    }

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      AppLoggerHelper.warning('Cannot start chat without authorization');
      return;
    }

    final customerId = await _resolveCurrentUserId(authorization);
    if (customerId == null || customerId.isEmpty) {
      AppLoggerHelper.warning('Cannot start chat without customer id');
      return;
    }

    final started = await _chatSessionApiService.startChat(
      authorization: authorization,
      fromType: 'customer',
      fromId: customerId,
      toType: 'installer',
      toId: cleanedInstallerId,
    );

    if (!started) {
      AppLoggerHelper.warning('Failed to start chat with $cleanedInstallerId');
      return;
    }

    final conversation = Conversation(
      id: '${customerId}_$cleanedInstallerId',
      userId: cleanedInstallerId,
      userName: cleanedInstallerId,
      userAvatar: '',
      userType: 'installer',
      lastMessage: lastMessage ?? '',
      lastMessageTime: lastMessageTime ?? DateTime.now(),
    );

    Get.toNamed(AppRoute.getMessagingScreen(), arguments: conversation);
  }

  Future<String?> _resolveCurrentUserId(String authorization) async {
    final tokenSub = AuthTokenHelper.getSubjectFromJwt(
      StorageService.accessToken,
    );
    if (tokenSub != null && tokenSub.isNotEmpty) {
      await StorageService.saveUserId(tokenSub);
      return tokenSub;
    }

    final cachedId = StorageService.userId?.trim();
    if (cachedId != null && cachedId.isNotEmpty) {
      return cachedId;
    }

    try {
      final profile = await _userProfileApiService.fetchCurrentUser(
        authorization: authorization,
      );
      return profile.id.trim().isEmpty ? null : profile.id.trim();
    } catch (error) {
      AppLoggerHelper.warning('Failed to resolve customer id for chat: $error');
      return null;
    }
  }
}
