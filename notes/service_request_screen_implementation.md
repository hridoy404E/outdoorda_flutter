# Service Request Screen Implementation Guide

## 📋 Overview

This document provides a comprehensive guide for implementing the Service Request screen in the Outdoorda Flutter application. The screen follows the Figma design with pixel-perfect accuracy and implements full functionality using the MVC architecture pattern.

## 🎯 Learning Objectives

By studying this implementation, you will learn:
- How to create reusable widgets following DRY principles
- Proper MVC architecture separation in Flutter
- Responsive design using `flutter_screenutil`
- State management with GetX
- Creating pixel-perfect UI matching Figma designs
- Building complex list-based layouts with multiple sections

## 🏗 Architecture Overview

### MVC Pattern Implementation

```
Model (Data Layer)
├── ServiceRequest - Represents service request data
└── Review - Represents customer review data

View (Presentation Layer)
├── ServiceRequestScreen - Main screen widget
└── Reusable Widgets:
    ├── CustomAppBar - Top app bar with greeting and profile
    ├── OngoingServiceCard - Gradient card for active service
    ├── QuickActions - Action buttons section
    ├── HistoryCard - Service history with status badges
    └── ReviewCard - Customer review card with ratings

Controller (Business Logic Layer)
└── ServiceRequestController - Manages state and user interactions
```

## 📁 File Structure

```
lib/features/customer_section/home/service_request/
├── controllers/
│   └── service_request_controller.dart
├── models/
│   ├── service_request_model.dart
│   └── review_model.dart
└── views/
    ├── screens/
    │   └── service_request_screen.dart
    └── widgets/
        ├── history_card.dart
        ├── ongoing_service_card.dart
        ├── quick_actions.dart
        └── review_card.dart

lib/core/common/widgets/
└── custom_appbar.dart
```

## 🎨 Design Specifications

### Color Palette

Based on the Figma design, we added the following colors to `AppColors`:

```dart
// Status Badge Colors
static const Color ongoingBadge = Color(0xFF8B4EFF);           // Purple
static const Color installerAssignedBadge = Color(0xFF0EA5E9); // Blue
static const Color receivingBidsBadge = Color(0xFFFF9500);     // Orange
static const Color completedBadge = Color(0xFF22C55E);         // Green

// Background Colors
static const Color cardBackground = Color(0xFFFFFFFF);
static const Color sectionBackground = Color(0xFFF8F9FA);
static const Color iconBackground = Color(0xFFF0F9FF);

// Gradient Colors
static const Color ongoingCardGradientStart = Color(0xFF6FAACC);
static const Color ongoingCardGradientEnd = Color(0xFF395C70);

// Accent Colors
static const Color orangeAccent = Color(0xFFFF9500);
static const Color starYellow = Color(0xFFFBBC05);
```

### Typography

We use the `figtreeTextStyle` helper from `global_text_style.dart`:

```dart
// Headings
figtreeTextStyle(fontSize: 18, fontWeight: FontWeight.w600)

// Body Text
figtreeTextStyle(fontSize: 14, fontWeight: FontWeight.w400)

// Labels
figtreeTextStyle(fontSize: 12, fontWeight: FontWeight.w500)
```

### Spacing & Sizing

Using `flutter_screenutil` for responsive design:
- Card padding: `16.r`
- Section spacing: `24.h`
- Card margin: `12.h`
- Border radius: `12.r`

## 📝 Step-by-Step Implementation

### Step 1: Define Data Models

#### ServiceRequest Model
```dart
class ServiceRequest {
  final String id;
  final String title;
  final String address;
  final String installerName;
  final String installerImageUrl;
  final String status;
  final String date;
  final String? price;
  final String? additionalInfo;

  // Constructor with required fields
  // fromJson factory for API integration
  // toJson method for data serialization
}
```

**Key Features:**
- Null-safe design with optional fields
- `fromJson` factory for API data parsing
- `toJson` method for data serialization
- Proper default values in `fromJson`

#### Review Model
```dart
class Review {
  final String id;
  final String reviewerName;
  final String reviewerImageUrl;
  final String petName;
  final String reviewText;
  final double rating;

  // Constructor, fromJson, and toJson
}
```

### Step 2: Create the Controller

The `ServiceRequestController` manages all business logic:

```dart
class ServiceRequestController extends GetxController {
  // Observable lists for reactive UI
  final RxList<ServiceRequest> ongoingServices = <ServiceRequest>[].obs;
  final RxList<ServiceRequest> historyServices = <ServiceRequest>[].obs;
  final RxList<Review> happyTailsReviews = <Review>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData(); // Load initial data
    AppLoggerHelper.info('ServiceRequestController initialized');
  }

  // Navigation methods
  void onNewRequestTap() { /* Navigate to new request */ }
  void onMessageTap() { /* Navigate to messages */ }
  void onHelpCenterTap() { /* Navigate to help center */ }
}
```

**Best Practices:**
- All lists are observable (`RxList`) for reactive UI updates
- Business logic is centralized in controller methods
- Proper logging using `AppLoggerHelper`
- Navigation methods are prepared for future routing

### Step 3: Build Reusable Widgets

#### CustomAppBar Widget

A reusable app bar component that can be used across the app:

```dart
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.greetingText,
    required this.userType,
    this.profileImageUrl,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(70.h);
}
```

**Features:**
- Implements `PreferredSizeWidget` for Scaffold compatibility
- Displays logo, greeting, user type, and profile image
- Responsive sizing using `flutter_screenutil`
- Optional profile tap callback

#### OngoingServiceCard Widget

Displays the current active service with gradient background:

```dart
class OngoingServiceCard extends StatelessWidget {
  // Gradient background with status badge
  // Service title and address
  // Assigned installer section with chevron
}
```

**Design Elements:**
- Gradient background from Figma design
- Purple "Ongoing" status badge
- Location icon with address
- White container for installer info
- Tap handlers for navigation

#### HistoryCard Widget

Reusable card supporting 3 different status types:

```dart
class HistoryCard extends StatelessWidget {
  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'Installer Assigned':
        return BlueBadge();
      case 'Receiving Bids':
        return OrangeBadge();
      case 'Completed':
        return GreenBadge();
    }
  }
}
```

**Features:**
- Dynamic status badge with color coding
- Installer avatar and name
- Price display for assigned services
- Additional info for pending services
- Shadow effect for depth

#### ReviewCard Widget

Horizontal scrolling card for customer reviews:

```dart
class ReviewCard extends StatelessWidget {
  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: AppColors.starYellow,
        );
      }),
    );
  }
}
```

**Features:**
- 5-star rating display
- Review text with ellipsis
- Reviewer avatar and name
- Pet name display
- Fixed width for horizontal scrolling

#### QuickActions Widget

Three action buttons with icons:

```dart
class QuickActions extends StatelessWidget {
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    // Icon in colored background
    // Label text below
    // Tap handling
  }
}
```

**Features:**
- Equal spacing between buttons
- Icon in light blue background
- Label text below icon
- Shadow effect for elevation

### Step 4: Implement the Main Screen

The `ServiceRequestScreen` combines all widgets:

```dart
class ServiceRequestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceRequestController>();

    return Scaffold(
      backgroundColor: AppColors.sectionBackground,
      appBar: CustomAppBar(...),
      body: Obx(() => ListView(
        children: [
          OngoingServiceCard(...),
          QuickActions(...),
          HistorySection(...),
          HappyTailsSection(...),
        ],
      )),
    );
  }
}
```

**Layout Structure:**
1. **CustomAppBar** - Top app bar with greeting and profile
2. **OngoingServiceCard** - Current active service
3. **QuickActions** - Three action buttons
4. **Your History** - List of past services with status badges
5. **Happy Tails** - Horizontal scrolling reviews

**Key Implementation Details:**
- `Obx` wrapper for reactive UI updates
- `ListView` for scrollable content (better than `SingleChildScrollView` + `Column`)
- Conditional rendering with `if` statements
- Proper padding and spacing throughout

### Step 5: Register Controller

Add controller to `controller_binder.dart`:

```dart
class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    // ... other controllers

    Get.lazyPut<ServiceRequestController>(
      () => ServiceRequestController(),
      fenix: true,
    );
  }
}
```

**Why lazyPut with fenix?**
- `lazyPut` - Controller is created only when first accessed
- `fenix: true` - Controller is recreated if disposed and accessed again
- Better memory management for non-critical controllers

## 🔍 Common Issues and Solutions

### Issue 1: Images Not Loading

**Problem:** Network images showing placeholder icon

**Solution:**
```dart
// Add internet permission in AndroidManifest.xml
<uses-permission android:name="android.permission.INTERNET"/>

// Use proper error handling
Container(
  decoration: BoxDecoration(
    image: profileImageUrl != null
        ? DecorationImage(
            image: NetworkImage(profileImageUrl!),
            fit: BoxFit.cover,
            onError: (error, stackTrace) {
              AppLoggerHelper.error('Image load error', error);
            },
          )
        : null,
  ),
  child: profileImageUrl == null ? Icon(Icons.person) : null,
)
```

### Issue 2: Overflow Errors

**Problem:** Content overflowing on smaller screens

**Solution:**
- Use `flutter_screenutil` for all sizing
- Wrap text in `Expanded` or `Flexible` widgets
- Set `overflow: TextOverflow.ellipsis` for long text

### Issue 3: Controller Not Found

**Problem:** `Get.find<ServiceRequestController>()` throws error

**Solution:**
1. Ensure controller is registered in `controller_binder.dart`
2. Make sure `ControllerBinder()` is used in `GetMaterialApp`
3. Use `Get.put()` temporarily for debugging

### Issue 4: ListView Not Scrolling

**Problem:** ListView doesn't scroll properly

**Solution:**
```dart
// Don't wrap ListView in Column with no Expanded
// ❌ Wrong
Column(
  children: [
    ListView(...), // Won't scroll
  ],
)

// ✅ Correct
ListView(
  children: [
    // All content here
  ],
)
```

## 🧪 Testing Guidelines

### Manual Testing Checklist

1. **UI Rendering**
   - [ ] App bar displays correctly with greeting and profile
   - [ ] Ongoing service card shows with gradient background
   - [ ] Quick action buttons are evenly spaced
   - [ ] History cards show with correct status badges
   - [ ] Happy Tails section scrolls horizontally
   - [ ] All text is readable and properly sized

2. **Interactions**
   - [ ] Profile icon tap works
   - [ ] Ongoing service card tap works
   - [ ] Quick action buttons respond to taps
   - [ ] History card taps work
   - [ ] Installer info taps work
   - [ ] Happy Tails cards scroll smoothly

3. **Responsive Design**
   - [ ] Layout works on different screen sizes
   - [ ] Text scales appropriately
   - [ ] Images maintain aspect ratio
   - [ ] Spacing is consistent

### Widget Testing

```dart
testWidgets('ServiceRequestScreen displays ongoing service', (tester) async {
  // Initialize GetX
  Get.testMode = true;
  Get.put(ServiceRequestController());

  // Build widget
  await tester.pumpWidget(
    MaterialApp(home: ServiceRequestScreen()),
  );

  // Verify widgets
  expect(find.text('Good Morning'), findsOneWidget);
  expect(find.text('Ongoing'), findsOneWidget);
  expect(find.text('Large Electronic Door'), findsOneWidget);
});
```

## 🚀 Performance Considerations

### Optimization Techniques

1. **Image Caching**
   ```dart
   // Use cached_network_image package
   CachedNetworkImage(
     imageUrl: service.installerImageUrl,
     placeholder: (context, url) => CircularProgressIndicator(),
     errorWidget: (context, url, error) => Icon(Icons.error),
   )
   ```

2. **List Performance**
   ```dart
   // Happy Tails uses ListView.builder for better performance
   ListView.builder(
     itemCount: controller.happyTailsReviews.length,
     itemBuilder: (context, index) {
       return ReviewCard(review: controller.happyTailsReviews[index]);
     },
   )
   ```

3. **Const Constructors**
   ```dart
   // Use const for static widgets
   const SizedBox(height: 12)
   const Icon(Icons.star)
   ```

4. **Reactive State Management**
   ```dart
   // Only specific widgets rebuild when data changes
   Obx(() => Text(controller.ongoingServices.first.title))
   ```

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [Flutter ScreenUtil](https://pub.dev/packages/flutter_screenutil)
- [Google Fonts](https://pub.dev/packages/google_fonts)

## 🎓 Key Takeaways

1. **Reusable Widgets**: Extract repeated patterns into reusable widgets
2. **MVC Architecture**: Keep business logic in controllers, not in widgets
3. **Package Imports**: Always use package imports for files in `lib/`
4. **Responsive Design**: Use `flutter_screenutil` for all sizing
5. **State Management**: Use GetX observables for reactive UI
6. **Constants**: Use `AppStrings` and `AppColors` for consistency
7. **Logging**: Use `AppLoggerHelper` for all logging
8. **Error Handling**: Handle errors gracefully with try-catch
9. **Performance**: Use `ListView.builder` for long lists
10. **Documentation**: Comment complex logic, not obvious code

## 🔄 Future Enhancements

- Add pull-to-refresh functionality
- Implement real API integration
- Add shimmer loading states
- Implement pagination for history
- Add filters for service status
- Implement search functionality
- Add animations for card interactions
- Implement offline mode with local storage

---

**Created:** November 25, 2025  
**Last Updated:** November 25, 2025  
**Version:** 1.0.0
