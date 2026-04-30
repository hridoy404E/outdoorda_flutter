# Multi-Question Rating System Implementation

## Overview
This document explains the implementation of a comprehensive multi-question rating system for service reviews. Instead of a single overall rating, users now answer multiple specific questions about their installer experience, and the system calculates an average rating.

## Learning Objectives
- Understand how to implement multi-step rating flows
- Learn to use dropdown selection for dynamic content
- Master state management with GetX for complex forms
- Implement average calculation from multiple ratings
- Create reusable rating widgets

## Architecture (MVC Pattern)

### Model Layer
- **ServiceRequest**: Contains service details and ID for review submission
- **Rating Data Structure**: Map-based storage for question-rating pairs

### View Layer
1. **ReviewCardWidget** (`submit_review_card.dart`): Main container for the review form
2. **RatingQuestionItem** (`rating_question_item.dart`): Reusable widget for displaying rated questions

### Controller Layer
- **ReviewController** (`review_controller.dart`): Manages all rating logic, validation, and submission

---

## Implementation Guide

### Step 1: Add Rating Questions to AppStrings

**File**: `lib/core/utils/constants/app_strings.dart`

```dart
// Rating Questions
static const String selectQuestion = 'Select a question to rate';
static const String questionInstallerOnTime = 'Was the installer on time?';
static const String questionInstallerOrganized = 
    'Was the installer organized and have all his tools?';
static const String questionInstallerCleanup = 
    'Did the installer clean up after the job was finished?';
static const String questionFinishedProductAcceptable = 
    'Was the finished product acceptable?';
static const String rateAllQuestions = 'Please rate all questions';
static const String averageRating = 'Average Rating';
```

**Purpose**: Centralize all user-facing strings for easy maintenance and potential localization.

---

### Step 2: Update ReviewController with Multi-Question Logic

**File**: `lib/features/customer_section/home/service_request/controllers/review_controller.dart`

#### Key Features:

**1. Question List Management**
```dart
final List<String> ratingQuestions = [
  AppStrings.questionInstallerOnTime,
  AppStrings.questionInstallerOrganized,
  AppStrings.questionInstallerCleanup,
  AppStrings.questionFinishedProductAcceptable,
];
```
- Stores all available questions
- Easy to add/remove questions
- Order determines display sequence

**2. Rating Storage**
```dart
final RxMap<int, double> questionRatings = <int, double>{}.obs;
```
- Maps question index (0-3) to rating (1.0-5.0)
- Observable for reactive UI updates
- Sparse map: only stores rated questions

**3. Dropdown Selection**
```dart
final Rxn<int> selectedQuestionIndex = Rxn<int>();
```
- Tracks currently selected question in dropdown
- `Rxn` allows nullable value (no selection initially)
- Updates UI when user selects a question

**4. Rating Management**
```dart
void setRating(double value) {
  if (selectedQuestionIndex.value != null) {
    questionRatings[selectedQuestionIndex.value!] = value;
    AppLoggerHelper.debug(
      'Rating set for question ${selectedQuestionIndex.value}: $value',
    );
  }
}
```
- Only sets rating if a question is selected
- Overwrites previous rating if user changes it
- Logs action for debugging

**5. Validation**
```dart
bool get allQuestionsRated {
  return questionRatings.length == ratingQuestions.length &&
      questionRatings.values.every((rating) => rating > 0);
}
```
- Ensures all 4 questions have ratings
- Prevents submission with incomplete data
- Returns `true` only when all questions are answered

**6. Average Calculation**
```dart
double get averageRating {
  if (questionRatings.isEmpty) return 0.0;
  final sum = questionRatings.values.reduce((a, b) => a + b);
  return sum / questionRatings.length;
}
```
- Calculates mean of all ratings
- Returns 0.0 if no ratings yet
- Used for final submission and display

**7. Submission with Validation**
```dart
Future<void> submitReview(String serviceId) async {
  // Validate that all questions are rated
  if (!allQuestionsRated) {
    EasyLoading.showError(AppStrings.rateAllQuestions);
    return;
  }

  try {
    isSubmitting.value = true;
    EasyLoading.show();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Log the review submission
    AppLoggerHelper.info(
      'Review submitted for service $serviceId: '
      'Average Rating: ${averageRating.toStringAsFixed(1)}, '
      'Individual Ratings: $questionRatings, '
      'Comment: ${reviewTextController.text}',
    );

    isReviewSubmitted.value = true;
    EasyLoading.showSuccess(AppStrings.reviewSubmittedSuccess);
  } catch (error) {
    AppLoggerHelper.error('Failed to submit review', error);
    EasyLoading.showError(AppStrings.reviewSubmitError);
  } finally {
    isSubmitting.value = false;
    EasyLoading.dismiss();
  }
}
```
- Validates all questions are rated before submission
- Shows loading state during API call
- Logs detailed review data including individual ratings
- Handles errors gracefully

---

### Step 3: Create Reusable Rating Question Widget

**File**: `lib/features/customer_section/home/service_request/views/widgets/rating_question_item.dart`

```dart
class RatingQuestionItem extends StatelessWidget {
  const RatingQuestionItem({
    super.key,
    required this.question,
    required this.rating,
    required this.onRatingChanged,
    required this.isEnabled,
  });

  final String question;
  final double rating;
  final Function(double) onRatingChanged;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.neutral25,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Text(question, style: /* ... */),
          SizedBox(height: 12.h),

          // Star rating
          Row(
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return GestureDetector(
                onTap: isEnabled
                    ? () => onRatingChanged(starIndex.toDouble())
                    : null,
                child: Icon(
                  rating >= starIndex ? Icons.star : Icons.star_border,
                  size: 28.r,
                  color: rating >= starIndex
                      ? const Color(0xFFFBBC05)
                      : AppColors.textSecondary,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
```

**Purpose**: 
- Display individual rated questions with their ratings
- Allow users to modify ratings by tapping stars
- Disable interaction after submission
- Consistent styling across all questions

---

### Step 4: Update ReviewCardWidget UI

**File**: `lib/features/customer_section/home/service_request/views/widgets/submit_review_card.dart`

#### UI Flow:

**1. Dropdown for Question Selection**
```dart
if (!controller.isReviewSubmitted.value) ...[
  Container(
    // ... styling
    child: DropdownButton<int>(
      value: controller.selectedQuestionIndex.value,
      hint: Text(AppStrings.selectQuestion),
      items: List.generate(
        controller.ratingQuestions.length,
        (index) => DropdownMenuItem<int>(
          value: index,
          child: Text(controller.ratingQuestions[index]),
        ),
      ),
      onChanged: (value) {
        controller.selectedQuestionIndex.value = value;
      },
    ),
  ),
]
```
- Shows all 4 questions in dropdown
- User selects one to rate
- Hides after review submission

**2. Star Rating for Selected Question**
```dart
if (!controller.isReviewSubmitted.value &&
    controller.selectedQuestionIndex.value != null) ...[
  Container(
    // ... styling
    child: Column(
      children: [
        Text(controller.ratingQuestions[
            controller.selectedQuestionIndex.value!]),
        Row(
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final currentRating = controller.getRating(
                controller.selectedQuestionIndex.value!);
            return GestureDetector(
              onTap: () => controller.setRating(starIndex.toDouble()),
              child: Icon(
                currentRating >= starIndex
                    ? Icons.star
                    : Icons.star_border,
              ),
            );
          }),
        ),
      ],
    ),
  ),
]
```
- Displays selected question with star rating
- Updates controller when user taps stars
- Shows current rating for that question

**3. List of All Rated Questions**
```dart
if (controller.questionRatings.isNotEmpty) ...[
  Text('Rated Questions:'),
  ...controller.questionRatings.entries.map((entry) {
    return RatingQuestionItem(
      question: controller.ratingQuestions[entry.key],
      rating: entry.value,
      onRatingChanged: (newRating) {
        controller.selectedQuestionIndex.value = entry.key;
        controller.setRating(newRating);
      },
      isEnabled: !controller.isReviewSubmitted.value,
    );
  }),
]
```
- Shows all questions that have been rated
- Allows users to modify ratings
- Uses reusable `RatingQuestionItem` widget

**4. Average Rating Display**
```dart
if (controller.allQuestionsRated) ...[
  Container(
    // Gradient background
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppStrings.averageRating),
        Row(
          children: [
            Text(controller.averageRating.toStringAsFixed(1)),
            Icon(Icons.star, color: Color(0xFFFBBC05)),
          ],
        ),
      ],
    ),
  ),
]
```
- Shows average rating once all questions are answered
- Prominent display with gradient background
- Format: "3.8 ⭐"

**5. Submit Button with Validation**
```dart
if (!controller.isReviewSubmitted.value)
  GestureDetector(
    onTap: controller.isSubmitting.value
        ? null
        : () => controller.submitReview(service.id),
    child: Container(
      // Gradient button styling
      child: controller.isSubmitting.value
          ? CircularProgressIndicator()
          : Text(AppStrings.submitReview),
    ),
  ),
```
- Disabled during submission (prevents double-tap)
- Shows loading indicator while submitting
- Controller validates all questions are rated

---

## Common Issues and Solutions

### Issue 1: Dropdown Not Updating UI
**Problem**: Selected question doesn't update the UI.

**Solution**: Ensure `selectedQuestionIndex` is wrapped in `Obx()`:
```dart
Obx(() => DropdownButton<int>(
  value: controller.selectedQuestionIndex.value,
  // ...
))
```

### Issue 2: Star Rating Not Persisting
**Problem**: Star rating resets when switching questions.

**Solution**: Use `controller.getRating(index)` to retrieve saved rating:
```dart
final currentRating = controller.getRating(
    controller.selectedQuestionIndex.value!);
```

### Issue 3: Submit Button Active Without All Ratings
**Problem**: User can submit with incomplete ratings.

**Solution**: Controller validates in `submitReview()`:
```dart
if (!allQuestionsRated) {
  EasyLoading.showError(AppStrings.rateAllQuestions);
  return;
}
```

### Issue 4: Average Calculation Incorrect
**Problem**: Average doesn't match expected value.

**Solution**: Check `questionRatings` map in logs:
```dart
AppLoggerHelper.info('Individual Ratings: $questionRatings');
```

---

## Testing Guidelines

### Manual Testing Checklist:
1. ✅ Select first question from dropdown
2. ✅ Rate it with 3 stars
3. ✅ Verify it appears in "Rated Questions" list
4. ✅ Select second question and rate with 5 stars
5. ✅ Continue for all 4 questions
6. ✅ Verify average rating displays correctly
7. ✅ Try modifying a previous rating
8. ✅ Add review text (optional)
9. ✅ Submit review
10. ✅ Verify success message and disabled state

### Edge Cases:
- Submitting without rating all questions → Error message
- Changing rating after initial selection → Should update
- Rapid clicks on submit button → Should prevent duplicate submissions

---

## Performance Considerations

### Optimization Techniques:
1. **Reactive State**: Only rebuilds affected widgets using `Obx()`
2. **Lazy Loading**: Questions loaded from constants, not fetched
3. **Efficient Map**: Sparse map only stores rated questions
4. **Single Controller**: Reuses one controller instance via `Get.find()`

### Memory Management:
- TextEditingController properly disposed in `onClose()`
- Observable collections automatically cleaned up by GetX
- No memory leaks from listeners

---

## API Integration (Future Enhancement)

When connecting to real backend:

```dart
Future<void> submitReview(String serviceId) async {
  if (!allQuestionsRated) {
    EasyLoading.showError(AppStrings.rateAllQuestions);
    return;
  }

  try {
    isSubmitting.value = true;
    EasyLoading.show();

    // Prepare request body
    final reviewData = {
      'service_id': serviceId,
      'average_rating': averageRating,
      'individual_ratings': {
        'on_time': questionRatings[0],
        'organized': questionRatings[1],
        'cleanup': questionRatings[2],
        'product_acceptable': questionRatings[3],
      },
      'comment': reviewTextController.text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // API call
    final response = await NetworkCaller.post(
      ApiConstants.submitReview,
      body: reviewData,
    );

    if (response.isSuccess) {
      isReviewSubmitted.value = true;
      EasyLoading.showSuccess(AppStrings.reviewSubmittedSuccess);
    } else {
      throw Exception(response.errorMessage);
    }
  } catch (error) {
    AppLoggerHelper.error('Failed to submit review', error);
    EasyLoading.showError(AppStrings.reviewSubmitError);
  } finally {
    isSubmitting.value = false;
    EasyLoading.dismiss();
  }
}
```

---

## Key Takeaways

1. **Multi-Question Rating**: More detailed feedback than single rating
2. **Map-Based Storage**: Efficient way to store question-rating pairs
3. **Dropdown Selection**: User-friendly interface for question navigation
4. **Average Calculation**: Provides overall score from individual ratings
5. **Reusable Widgets**: `RatingQuestionItem` for consistent UI
6. **Comprehensive Validation**: Ensures data quality before submission
7. **Reactive UI**: GetX observables for automatic UI updates
8. **Error Handling**: User-friendly messages with `EasyLoading`

---

## Extension Ideas

1. **Weighted Average**: Give more weight to certain questions
2. **Optional Questions**: Allow skipping specific questions
3. **Question Categories**: Group questions by type (timeliness, quality, etc.)
4. **Historical Ratings**: Show previous ratings for comparison
5. **Photo Upload**: Allow users to attach images to reviews
6. **Installer Response**: Enable installers to reply to reviews

---

## Conclusion

This multi-question rating system provides detailed, structured feedback about installer performance. The implementation follows Flutter best practices with proper state management, reusable components, and comprehensive validation. The code is maintainable, extendable, and easy for junior developers to understand and modify.
