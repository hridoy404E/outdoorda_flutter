import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/services/storage_service.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/utils/logging/logger.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/controllers/customar_home_controller.dart';
import 'package:outdoorda_flutter/features/customer_section/home/service_request/services/customer_review_api_service.dart';

/// Controller for managing review submission
/// Handles multiple rating questions and calculates average rating
class RequestDetailsController extends GetxController {
  final CustomerReviewApiService _customerReviewApiService =
      CustomerReviewApiService();

  // Rating questions list
  final List<String> ratingQuestions = [
    AppStrings.questionInstallerOnTime,
    AppStrings.questionInstallerOrganized,
    AppStrings.questionInstallerCleanup,
    AppStrings.questionFinishedProductAcceptable,
  ];

  // Map to store ratings for each question (question index -> rating)
  final RxMap<int, double> questionRatings = <int, double>{}.obs;

  // Loading state
  final RxBool isSubmitting = false.obs;

  // Track if review is already submitted
  final RxBool isReviewSubmitted = false.obs;

  // Customer note for the review
  final TextEditingController reviewNoteController = TextEditingController();

  @override
  void onClose() {
    reviewNoteController.dispose();
    super.onClose();
  }

  /// Set the star rating for a specific question
  void setRating(int questionIndex, double value) {
    questionRatings[questionIndex] = value;
    AppLoggerHelper.debug('Rating set for question $questionIndex: $value');
  }

  /// Get rating for a specific question
  double getRating(int questionIndex) {
    return questionRatings[questionIndex] ?? 0.0;
  }

  /// Check if all questions are rated
  bool get allQuestionsRated {
    return questionRatings.length == ratingQuestions.length &&
        questionRatings.values.every((rating) => rating > 0);
  }

  /// Calculate average rating
  double get averageRating {
    if (questionRatings.isEmpty) return 0.0;
    final sum = questionRatings.values.reduce((a, b) => a + b);
    return sum / questionRatings.length;
  }

  /// Submit the review
  Future<void> submitReview({
    required String serviceId,
    required String installerId,
  }) async {
    // Validate that all questions are rated
    if (!allQuestionsRated) {
      EasyLoading.showError(AppStrings.rateAllQuestions);
      return;
    }
    if (reviewNoteController.text.trim().isEmpty) {
      EasyLoading.showError(AppStrings.pleaseEnterReviewNote);
      return;
    }
    final cleanedInstallerId = installerId.trim();
    if (cleanedInstallerId.isEmpty) {
      EasyLoading.showError('Installer id not found');
      return;
    }

    final authorization = _buildAuthorizationHeader();
    if (authorization == null) {
      EasyLoading.showError(AppStrings.authorizationRequired);
      return;
    }

    try {
      isSubmitting.value = true;
      final integerRating = _buildIntegerRating();
      await _customerReviewApiService.submitReview(
        authorization: authorization,
        installerId: cleanedInstallerId,
        rating: integerRating,
        review: reviewNoteController.text.trim(),
      );

      // Log the review submission
      AppLoggerHelper.info(
        'Review submitted for service $serviceId: '
        'Installer: $cleanedInstallerId '
        'Rating: $integerRating, '
        'Individual Ratings: $questionRatings, '
        'Note: ${reviewNoteController.text.trim()}',
      );

      isReviewSubmitted.value = true;
      if (Get.isRegistered<CustomarHomeController>()) {
        await Get.find<CustomarHomeController>().refreshHappyTailsReviews();
      }
      EasyLoading.showSuccess(AppStrings.reviewSubmittedSuccess);
    } catch (error) {
      AppLoggerHelper.error('Failed to submit review', error);
      EasyLoading.showError(AppStrings.reviewSubmitError);
    } finally {
      isSubmitting.value = false;
      EasyLoading.dismiss();
    }
  }

  String? _buildAuthorizationHeader() {
    final token = StorageService.accessToken?.trim();
    if (token == null || token.isEmpty) return null;
    final type = StorageService.tokenType?.trim();
    final prefix = (type != null && type.isNotEmpty) ? type : 'Bearer';
    return '$prefix $token';
  }

  int _buildIntegerRating() {
    final rounded = averageRating.round();
    if (rounded < 1) return 1;
    if (rounded > 5) return 5;
    return rounded;
  }

  /// Reset the review form
  void resetReview() {
    questionRatings.clear();
    reviewNoteController.clear();
    isReviewSubmitted.value = false;
  }
}
