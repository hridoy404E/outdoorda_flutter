# All Requests & Request Details Screen Implementation

## Overview
This document explains the implementation of two interconnected screens: **All Requests Screen** and **Request Details Screen**. These screens allow customers to view their service requests and see detailed information including installer proposals.

## Learning Objectives
After reading this document, you will understand:
- How to create list screens with reusable card components
- Conditional navigation based on item status
- How to pass complex data between screens using GetX navigation
- Implementing pixel-perfect UI from Figma designs
- Building dynamic UI with conditional rendering

## Architecture (MVC Pattern)

### Model Layer
1. **ServiceRequest Model** (`service_request_model.dart`)
   - Contains all service request data including proposals
   - Fields: id, title, address, installerName, status, date, price, serviceType, petName, priceQuote, proposals list
   
2. **Proposal Model** (`proposal_model.dart`)
   - Represents installer offers/bids
   - Fields: id, installerName, installerImageUrl, rating, reviewCount, price, availableDate

### View Layer
1. **AllRequestsScreen** (`all_requests_screen.dart`)
   - Displays list of all service requests
   - Uses reusable `HistoryCard` widget
   - Conditional click handling based on status
   
2. **RequestsDetailsScreen** (`requests_details_screen.dart`)
   - Shows detailed information about selected request
   - Displays proposals (for "Receiving Bids" status)
   - Shows installation details
   - Conditional rendering based on request status

### Controller Layer
**ServiceRequestController** (`service_request_controller.dart`)
- Manages service request data
- Handles navigation logic with conditional behavior
- Provides mock data for demonstration

## Step-by-Step Implementation Guide

### Step 1: Update Models

#### Adding Proposal Model
```dart
/// Proposal model for installer offers
class Proposal {
  final String id;
  final String installerName;
  final String installerImageUrl;
  final double rating;
  final int reviewCount;
  final String price;
  final String availableDate;
  
  // Constructor, fromJson, and toJson methods
}
```

#### Extending ServiceRequest Model
```dart
class ServiceRequest {
  // Existing fields...
  final String? serviceType;
  final String? petName;
  final String? priceQuote;
  final List<Proposal>? proposals;  // NEW: List of installer proposals
}
```

**Why this matters**: The model acts as the single source of truth for data structure. Adding proposals to ServiceRequest allows us to associate multiple installer bids with a request.

### Step 2: Create All Requests Screen

#### Key Components:
1. **Header Section**
   - Title: "My Requests" (24sp, semibold)
   - Add button: Gradient background, 48x48, rounded corners (12r)

2. **Request List**
   - Uses `ListView.builder` for efficient rendering
   - Reuses existing `HistoryCard` widget
   - Horizontal padding: 20w

#### Conditional Click Handling:
```dart
HistoryCard(
  service: service,
  onTap: isCompleted
      ? null  // Completed items not clickable
      : () => controller.onServiceTap(service.id),
)
```

**Important**: Setting `onTap` to `null` for completed items makes them unresponsive to clicks.

### Step 3: Create Request Details Screen

#### Layout Structure:
1. **Status Card**
   - Shows current status badge
   - Displays proposal count for "Receiving Bids" status
   - White background with border

2. **Proposals Section** (Conditional)
   - Only shown when status == "Receiving Bids"
   - Each proposal card contains:
     - Installer profile (image, name, rating)
     - Price
     - Available date (only for Receiving Bids)
     - Action buttons (Chat, Accept Offer)

3. **Installation Details**
   - Service type
   - Door installation info
   - Pet information
   - Price quote
   - Address with location icon

#### Conditional Rendering Logic:
```dart
final bool showAvailableDate = service.status == AppStrings.receivingBids;

// In proposals list
if (showAvailableDate && service.proposals != null)
  ...service.proposals!.map(
    (proposal) => _buildProposalCard(
      proposal,
      showAvailableDate: showAvailableDate,
    ),
  ),
```

**Key Concept**: Use boolean flags for conditional rendering. This makes the code readable and maintainable.

### Step 4: Update Controller Navigation

#### Navigation Logic:
```dart
void onServiceTap(String serviceId) {
  // Find service by ID
  final service = historyServices.firstWhereOrNull((s) => s.id == serviceId);
  
  if (service != null) {
    // Navigate with service data as argument
    Get.toNamed(AppRoute.getRequestsDetailsScreen(), arguments: service);
  }
}
```

#### Receiving Data in Details Screen:
```dart
final ServiceRequest service = Get.arguments as ServiceRequest;
```

**Important**: Always validate that arguments exist before casting to avoid null errors.

### Step 5: Update Routes

```dart
static String allRequestsScreen = "/allRequestsScreen";
static String requestsDetailsScreen = "/requestsDetailsScreen";

static String getAllRequestsScreen() => allRequestsScreen;
static String getRequestsDetailsScreen() => requestsDetailsScreen;

static List<GetPage> routes = [
  // ... existing routes
  GetPage(name: allRequestsScreen, page: () => const AllRequestsScreen()),
  GetPage(name: requestsDetailsScreen, page: () => const RequestsDetailsScreen()),
];
```

## Code Examples with Explanations

### Example 1: Status Badge Builder
```dart
Widget _buildStatusBadge(String status) {
  LinearGradient badgeGradient;
  String badgeText;

  switch (status) {
    case 'Installer Assigned':
      badgeGradient = const LinearGradient(
        colors: [
          AppColors.installerAssignedStart,
          AppColors.installerAssignedEnd,
        ],
      );
      badgeText = AppStrings.installerAssigned;
      break;
    case 'Receiving Bids':
      badgeGradient = const LinearGradient(
        colors: [AppColors.receivingBidsStart, AppColors.receivingBidsEnd],
      );
      badgeText = AppStrings.receivingBids;
      break;
    default:
      badgeGradient = const LinearGradient(
        colors: [AppColors.neutral300, AppColors.neutral300],
      );
      badgeText = status;
  }

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
    decoration: BoxDecoration(
      gradient: badgeGradient,
      borderRadius: BorderRadius.circular(9999.r),
    ),
    child: Text(badgeText, style: textStyle),
  );
}
```

**Explanation**: This builder pattern allows us to reuse badge logic across multiple screens while maintaining consistency in appearance.

### Example 2: Proposal Card with Conditional Date
```dart
Widget _buildProposalCard(Proposal proposal, {required bool showAvailableDate}) {
  return Container(
    // ... card styling
    child: Column(
      children: [
        // Installer info row
        _buildInstallerInfo(proposal),
        
        // Conditionally show available date
        if (showAvailableDate) ...[
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.access_time),
              Text('Available ${proposal.availableDate}'),
            ],
          ),
        ],
        
        // Action buttons
        _buildActionButtons(proposal),
      ],
    ),
  );
}
```

**Explanation**: The spread operator `...` allows conditional widget insertion. The `if` statement is evaluated at build time, making the UI responsive to data state.

## Common Issues and Solutions

### Issue 1: Completed Items Still Clickable
**Problem**: Even though onTap is null, the card still responds to clicks.

**Solution**: Ensure HistoryCard widget properly handles null onTap:
```dart
GestureDetector(
  onTap: onTap,  // Will be null for completed items
  child: Container(...),
)
```

### Issue 2: Navigation Crashes with Null Arguments
**Problem**: App crashes when navigating to details screen.

**Solution**: Always pass service data as arguments:
```dart
Get.toNamed(AppRoute.getRequestsDetailsScreen(), arguments: service);
```

And validate on the receiving end:
```dart
final service = Get.arguments as ServiceRequest?;
if (service == null) {
  // Handle error - maybe navigate back
  Get.back();
  return;
}
```

### Issue 3: Available Date Shows for Wrong Status
**Problem**: Available date appears for "Installer Assigned" status.

**Solution**: Use strict equality check:
```dart
final bool showAvailableDate = service.status == AppStrings.receivingBids;
```

Never use `.contains()` or partial matching for status checks.

## Testing Guidelines

### Manual Testing Checklist:
1. **All Requests Screen**
   - [ ] Screen loads with list of requests
   - [ ] Add button navigates to new request form
   - [ ] "Installer Assigned" items are clickable
   - [ ] "Receiving Bids" items are clickable
   - [ ] "Completed" items are NOT clickable
   - [ ] All status badges show correct colors

2. **Request Details Screen**
   - [ ] Status badge displays correctly
   - [ ] Proposals show for "Receiving Bids" status
   - [ ] Available date shows for each proposal (Receiving Bids only)
   - [ ] Available date DOES NOT show for "Installer Assigned"
   - [ ] Installation details display correctly
   - [ ] Chat button is tappable
   - [ ] Accept Offer button is tappable
   - [ ] Address shows with location icon

### Test Scenarios:

**Scenario 1: View Installer Assigned Request**
1. Tap on "Large Electronic Door" with "Installer Assigned" status
2. Verify status badge is blue gradient
3. Verify NO proposals section appears
4. Verify NO available date in any section
5. Verify installation details show correctly

**Scenario 2: View Receiving Bids Request**
1. Tap on "Patio Panel" with "Receiving Bids" status
2. Verify status badge is orange gradient
3. Verify proposal cards appear
4. Verify each proposal shows available date
5. Verify "You have received 3 proposals..." text appears

**Scenario 3: Attempt to Click Completed Item**
1. Tap on completed service request card
2. Verify nothing happens (no navigation)
3. Card should not show visual feedback

## Performance Considerations

### Memory Management
- Use `const` constructors wherever possible
- ListView.builder loads items on demand
- Dispose controllers properly (handled by GetX fenix: true)

### Efficient Rendering
```dart
// ✅ Good: Only rebuilds list when data changes
Obx(() => ListView.builder(
  itemCount: controller.historyServices.length,
  itemBuilder: (context, index) {
    final service = controller.historyServices[index];
    return HistoryCard(service: service);
  },
))

// ❌ Bad: Rebuilds entire screen on any state change
Obx(() => Column(
  children: controller.historyServices.map((s) => HistoryCard(...)).toList(),
))
```

### Navigation Optimization
- Pass only necessary data as arguments
- Use lazy loading for routes with `GetPage`
- Controllers are lazily instantiated with `Get.lazyPut()`

## Figma Design Matching

### Colors (100% Match)
- Status badges use exact gradient colors from Figma
- Text colors match Figma tokens (neutral/400, neutral/900, etc.)
- Card backgrounds use Foundation/Blue/Light (#EBEFF1)

### Spacing (Pixel Perfect)
- Horizontal padding: 20w
- Card margin: 16h between items
- Internal card padding: 16r
- Button height: 44h
- Add button: 48x48

### Typography
- Title: 24sp, Figtree, Semibold
- Card title: 20sp, Figtree, Semibold
- Body text: 14sp, Figtree, Regular
- Status badge: 12sp, Figtree, Bold

### Border Radius
- Cards: 12r
- Buttons: 8r
- Status badges: 9999r (fully rounded)
- Add button: 12r

## Best Practices Applied

1. **Package Imports**: All imports use `package:outdoorda_flutter/...` format
2. **Color Methods**: Use `Color.withValues(alpha: ...)` instead of deprecated `.withOpacity()`
3. **GetX Controllers**: Use `Get.find<>()` instead of `Get.put()` in widgets
4. **Text Constants**: All strings from `AppStrings` class
5. **Logging**: Use `AppLoggerHelper` for all logging
6. **Reusable Widgets**: Leveraged existing `HistoryCard` widget
7. **Responsive Sizing**: All dimensions use `screen_utils` (.w, .h, .r)
8. **MVC Architecture**: Clear separation of model, view, and controller

## Files Created/Modified

### Created:
1. `/lib/features/customer_section/booking/all_requests/views/screens/all_requests_screen.dart`
2. `/lib/features/customer_section/booking/requests_details/views/screens/requests_details_screen.dart`
3. `/lib/features/customer_section/home/service_request/models/proposal_model.dart`

### Modified:
1. `/lib/core/utils/constants/app_strings.dart` - Added new string constants
2. `/lib/features/customer_section/home/service_request/models/service_request_model.dart` - Extended with new fields
3. `/lib/features/customer_section/home/service_request/controllers/service_request_controller.dart` - Added navigation logic and proposals
4. `/lib/routes/app_routes.dart` - Added new route definitions

## Conclusion

This implementation demonstrates a complete feature flow from list view to detail view with conditional behavior. The code is production-ready, follows all project guidelines, and maintains pixel-perfect design matching. The conditional rendering based on status (Installer Assigned vs Receiving Bids vs Completed) provides a dynamic user experience while keeping the code maintainable.

Key takeaways:
- Always use boolean flags for conditional rendering
- Pass complete data objects through navigation arguments
- Leverage existing reusable components
- Follow strict MVC pattern
- Match Figma designs 100% using exact values
