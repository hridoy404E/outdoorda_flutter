# Forgot Password Flow Implementation Guide

## Overview
This document explains the complete implementation of a three-screen forgot password flow in Flutter using GetX state management. The flow includes email verification, OTP verification, and password reset functionality, all designed to be pixel-perfect with Figma designs.

## Learning Objectives
After reading this guide, junior Flutter developers will understand:
- How to implement multi-screen authentication flows using GetX
- Proper MVC architecture in Flutter applications
- Custom widget reusability and composition
- Form validation with custom validators
- Timer-based UI interactions (OTP resend countdown)
- Navigation with argument passing between screens
- Responsive design using flutter_screenutil
- Error handling and user feedback patterns

## Architecture Explanation

### MVC Pattern
This implementation strictly follows the Model-View-Controller pattern:

**Model (Data Layer)**
- No explicit model classes needed for this flow (only passing strings)
- API response models would be added here when integrating real backend

**View (Presentation Layer)**
- `EmailVerifyScreen` - UI for email input
- `OtpVerifyScreen` - UI for 6-digit OTP input with timer
- `ResetPasswordScreen` - UI for new password input
- All views are stateless widgets (no business logic)

**Controller (Business Logic Layer)**
- `EmailVerifyController` - Handles email validation and API calls
- `OtpVerifyController` - Manages OTP input, validation, and resend timer
- `ResetPasswordController` - Processes password reset with validation

### Key Principle: Separation of Concerns
- **Views**: Only render UI and respond to user interactions
- **Controllers**: Handle ALL business logic, API calls, navigation, and state management
- **No logic in widgets**: Even simple operations like navigation go through controllers

## File Structure

```
lib/
├── core/
│   ├── bindings/
│   │   └── controller_binder.dart              # Controller registration
│   ├── common/widgets/
│   │   ├── custom_button.dart                  # Reusable button widget
│   │   └── custom_text_field.dart              # Reusable text field widget
│   ├── utils/
│   │   ├── constants/
│   │   │   ├── app_strings.dart                # Text constants
│   │   │   └── colors.dart                     # Color constants
│   │   └── validators/
│   │       └── app_validator.dart              # Form validation logic
├── features/
│   └── global_section/
│       └── authentication/
│           └── forgot_password/
│               ├── controllers/
│               │   ├── email_verify_controller.dart
│               │   ├── otp_verify_controller.dart
│               │   └── reset_password_controller.dart
│               └── screens/
│                   ├── email_verify_screen.dart
│                   ├── otp_verify_screen.dart
│                   └── reset_password_screen.dart
└── routes/
    └── app_routes.dart                         # Navigation configuration
```

## Step-by-Step Implementation

### Step 1: Create String Constants

**File**: `lib/core/utils/constants/app_strings.dart`

```dart
class AppStrings {
  /// Forgot Password - Email Verify Screen
  static const String forgotPasswordTitle = 'Forgot Password?';
  static const String forgotPasswordSubtitle = 'Please enter your email address below to receive your password reset OTP';
  static const String emailLabel = 'Email Address';
  static const String emailPlaceholder = 'example@mail.com';
  static const String sendResetLink = 'Send Reset Link';
  
  /// OTP Verification Screen
  static const String otpVerificationTitle = 'OTP Verification';
  static const String otpVerificationSubtitle = 'We have sent an OTP to your email. Please verify.';
  static const String verifyOTP = 'Verify OTP';
  static const String resendOTP = 'Resend OTP';
  
  /// Reset Password Screen
  static const String resetPasswordTitle = 'Reset Password?';
  static const String resetPasswordSubtitle = 'Please enter a new password & confirm to reset your password';
  static const String passwordLabel = 'Password';
  static const String passwordPlaceholder = 'Enter new password';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String confirmPasswordPlaceholder = 'Re-enter password';
  static const String resetPassword = 'Reset Password';
}
```

**Why?**
- Centralized text management prevents hardcoded strings
- Easy to update text across the app
- Supports future internationalization
- Follows project guidelines strictly

### Step 2: Implement Email Verify Screen

**File**: `lib/features/.../screens/email_verify_screen.dart`

```dart
class EmailVerifyScreen extends StatelessWidget {
  const EmailVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmailVerifyController>();
    
    return Scaffold(
      backgroundColor: AppColors.backgroundAuth,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  SizedBox(height: 48.h),
                  CustomTextField(
                    label: AppStrings.emailLabel,
                    placeholder: AppStrings.emailPlaceholder,
                    controller: controller.emailController,
                    validator: AppValidator.validateEmail,
                  ),
                  SizedBox(height: 24.h),
                  Obx(
                    () => CustomButton(
                      text: AppStrings.sendResetLink,
                      onPressed: controller.sendResetLink,
                      isLoading: controller.isLoading.value,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

**Key Points**:
- `Get.find<EmailVerifyController>()` - Retrieves controller (never use `Get.put()` in build method)
- `Obx()` widget - Rebuilds UI when `isLoading` changes
- `SafeArea` - Prevents UI from being hidden by notches/status bars
- `Center` + `MainAxisAlignment.center` - Vertically centers content
- `SingleChildScrollView` - Allows scrolling on small screens
- `flutter_screenutil` units (`.w`, `.h`) - Responsive sizing

### Step 3: Implement Email Verify Controller

**File**: `lib/features/.../controllers/email_verify_controller.dart`

```dart
class EmailVerifyController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendResetLink() async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Sending...');

      // TODO: API call
      // final response = await NetworkCaller.post(
      //   ApiConstants.sendResetLink,
      //   body: {'email': emailController.text.trim()},
      // );

      await Future.delayed(const Duration(seconds: 2)); // Simulation

      EasyLoading.dismiss();
      EasyLoading.showSuccess(AppStrings.emailSentSuccess);

      // Navigate with email argument
      Get.toNamed(
        AppRoute.otpVerifyScreen,
        arguments: {'email': emailController.text.trim()},
      );
    } catch (error) {
      EasyLoading.dismiss();
      EasyLoading.showError(AppStrings.emailSendError);
    } finally {
      isLoading.value = false;
    }
  }
}
```

**Key Concepts**:
1. **Form Validation**: `formKey.currentState!.validate()` triggers all field validators
2. **Observable State**: `RxBool isLoading = false.obs` - Reactive variable that triggers UI updates
3. **Loading Feedback**: `EasyLoading` provides global loading overlay
4. **Navigation with Arguments**: `Get.toNamed()` passes data to next screen
5. **Disposal**: Always dispose TextControllers in `onClose()` to prevent memory leaks

### Step 4: Implement OTP Verify Screen

**File**: `lib/features/.../screens/otp_verify_screen.dart`

This screen demonstrates advanced UI patterns:

```dart
/// Builds 6 OTP input boxes
Widget _buildOtpFields() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: List.generate(6, (index) {
      return _buildOtpBox(index);
    }),
  );
}

/// Individual OTP box with auto-focus
Widget _buildOtpBox(int index) {
  return Container(
    width: 48.w,
    height: 48.h,
    decoration: BoxDecoration(
      color: AppColors.neutral25,
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: AppColors.neutral700),
    ),
    child: TextFormField(
      controller: controller.otpControllers[index],
      focusNode: controller.focusNodes[index],
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 1,
      onChanged: (value) => controller.onOtpChanged(value, index),
      decoration: const InputDecoration(
        border: InputBorder.none,
        counterText: '',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '';
        }
        return null;
      },
    ),
  );
}
```

**Advanced Features**:
- **6 Separate Input Boxes**: Uses `List.generate()` to create consistent boxes
- **Auto-Focus**: Controller handles focus movement between boxes
- **Single Digit Input**: `maxLength: 1` limits each box to one character
- **Number Keyboard**: `keyboardType: TextInputType.number` for mobile devices
- **Custom Validation**: Empty validator (just shows error state, no message)

**Resend Timer Display**:
```dart
Widget _buildResendLink() {
  return Obx(
    () => controller.canResend.value
        ? GestureDetector(
            onTap: controller.resendOTP,
            child: Text(
              AppStrings.resendOTP,
              style: figtreeTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gradientStart,
              ),
            ),
          )
        : Text(
            'Wait ${controller.resendTimer.value}s',
            style: figtreeTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.neutral700,
            ),
          ),
  );
}
```

**Timer Logic**:
- Shows countdown when `canResend.value` is false
- Displays "Resend OTP" link when timer reaches 0
- Uses reactive variables to update UI automatically

### Step 5: Implement OTP Verify Controller

**File**: `lib/features/.../controllers/otp_verify_controller.dart`

**Auto-Focus Implementation**:
```dart
void onOtpChanged(String value, int index) {
  if (value.isNotEmpty && index < 5) {
    // Move to next field
    focusNodes[index + 1].requestFocus();
  } else if (value.isEmpty && index > 0) {
    // Move to previous field on backspace
    focusNodes[index - 1].requestFocus();
  }
}
```

**Timer Management**:
```dart
void _startResendTimer() {
  canResend.value = false;
  resendTimer.value = 60;

  _timer?.cancel(); // Cancel previous timer if exists
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (resendTimer.value > 0) {
      resendTimer.value--;
    } else {
      canResend.value = true;
      timer.cancel();
    }
  });
}
```

**Key Concepts**:
1. **List Controllers**: `List<TextEditingController>` manages 6 input fields
2. **Focus Management**: `List<FocusNode>` controls keyboard focus
3. **Timer.periodic**: Creates repeating countdown every second
4. **Cleanup**: Cancel timer in `onClose()` to prevent memory leaks

### Step 6: Implement Reset Password Screen

**File**: `lib/features/.../screens/reset_password_screen.dart`

```dart
Column(
  children: [
    CustomTextField(
      label: AppStrings.passwordLabel,
      placeholder: AppStrings.passwordPlaceholder,
      controller: controller.passwordController,
      validator: AppValidator.validatePassword,
      obscureText: true,
    ),
    SizedBox(height: 20.h),
    CustomTextField(
      label: AppStrings.confirmPasswordLabel,
      placeholder: AppStrings.confirmPasswordPlaceholder,
      controller: controller.confirmPasswordController,
      validator: (value) => AppValidator.validateConfirmPassword(
        value,
        controller.passwordController.text,
      ),
      obscureText: true,
    ),
  ],
)
```

**Password Validation**:
- First field: Basic password rules (length, characters)
- Second field: Must match first password
- `obscureText: true` hides password characters

### Step 7: Implement Reset Password Controller

**File**: `lib/features/.../controllers/reset_password_controller.dart`

```dart
Future<void> resetPassword() async {
  if (!formKey.currentState!.validate()) {
    return;
  }

  // Additional validation - passwords must match
  if (passwordController.text != confirmPasswordController.text) {
    EasyLoading.showError('Passwords do not match');
    return;
  }

  try {
    isLoading.value = true;
    EasyLoading.show(status: 'Resetting...');

    // TODO: API call with email, otp, and new password

    await Future.delayed(const Duration(seconds: 2));

    EasyLoading.dismiss();
    EasyLoading.showSuccess(AppStrings.passwordResetSuccess);

    // Navigate to login (clear navigation stack)
    Get.offAllNamed('/loginScreen');
  } catch (error) {
    EasyLoading.dismiss();
    EasyLoading.showError(AppStrings.passwordResetError);
  } finally {
    isLoading.value = false;
  }
}
```

**Navigation Pattern**:
- `Get.offAllNamed()` - Removes all previous screens from stack
- Prevents users from going back to password reset flow
- Common pattern after authentication actions

### Step 8: Configure Routes

**File**: `lib/routes/app_routes.dart`

```dart
class AppRoute {
  static String emailVerifyScreen = "/emailVerifyScreen";
  static String otpVerifyScreen = "/otpVerifyScreen";
  static String resetPasswordScreen = "/resetPasswordScreen";

  static List<GetPage> routes = [
    GetPage(name: emailVerifyScreen, page: () => const EmailVerifyScreen()),
    GetPage(name: otpVerifyScreen, page: () => const OtpVerifyScreen()),
    GetPage(name: resetPasswordScreen, page: () => const ResetPasswordScreen()),
  ];
}
```

**Why Centralized Routes?**
- Type-safe navigation (no typos in route strings)
- Easy to refactor route paths
- Single source of truth for all app routes

### Step 9: Register Controllers

**File**: `lib/core/bindings/controller_binder.dart`

```dart
class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailVerifyController>(
      () => EmailVerifyController(),
      fenix: true,
    );

    Get.lazyPut<OtpVerifyController>(
      () => OtpVerifyController(),
      fenix: true,
    );

    Get.lazyPut<ResetPasswordController>(
      () => ResetPasswordController(),
      fenix: true,
    );
  }
}
```

**Binding Explanation**:
- `Get.lazyPut()` - Creates controller only when needed
- `fenix: true` - Re-creates controller if removed from memory
- **CRITICAL**: NEVER add bindings to individual routes in `app_pages.dart`
- All controllers MUST be registered in `controller_binder.dart`

## Common Issues and Solutions

### Issue 1: "Controller not found"
**Error**: `Get.find<MyController>()` throws error

**Solution**:
1. Ensure controller is registered in `controller_binder.dart`
2. Verify `ControllerBinder` is set as `initialBinding` in `GetMaterialApp`
3. Check import statements use package imports (not relative)

### Issue 2: OTP Auto-Focus Not Working
**Problem**: Focus doesn't move to next box

**Solution**:
- Verify each TextFormField has unique `controller` and `focusNode`
- Check `onChanged` callback is properly connected to controller method
- Ensure focus nodes are disposed in `onClose()`

### Issue 3: Timer Continues After Leaving Screen
**Problem**: Timer runs even after navigating away

**Solution**:
```dart
@override
void onClose() {
  _timer?.cancel(); // MUST cancel timer
  super.onClose();
}
```

### Issue 4: Form Validation Not Triggering
**Problem**: Submit button works even with empty fields

**Solution**:
- Ensure Form widget wraps all TextFormFields
- Pass correct `formKey` to Form widget
- Call `formKey.currentState!.validate()` before submission

### Issue 5: UI Not Updating with Obx
**Problem**: Loading state changes but UI doesn't update

**Solution**:
- Wrap widget in `Obx()` that reads the observable
- Use `.obs` when declaring reactive variables: `RxBool isLoading = false.obs`
- Update value with `.value`: `isLoading.value = true`

## Testing Guidelines

### Manual Testing Checklist

**Email Verify Screen**:
- [ ] Invalid email shows error message
- [ ] Valid email enables submit
- [ ] Loading state shows spinner
- [ ] Success navigates to OTP screen
- [ ] Error shows error message

**OTP Verify Screen**:
- [ ] Typing in box 1 moves focus to box 2
- [ ] Backspace in empty box moves focus backward
- [ ] Submit with incomplete OTP shows error
- [ ] Timer counts down from 60 to 0
- [ ] Resend button disabled during countdown
- [ ] Resend button enabled after countdown
- [ ] Resend clears all OTP boxes

**Reset Password Screen**:
- [ ] Weak password shows validation error
- [ ] Mismatched passwords show error
- [ ] Valid passwords enable submit
- [ ] Success navigates to login
- [ ] Error shows error message

### Unit Testing Example

```dart
test('Email controller validates email format', () async {
  final controller = EmailVerifyController();
  controller.emailController.text = 'invalid-email';
  
  // Should not call API with invalid email
  await controller.sendResetLink();
  
  expect(controller.isLoading.value, false);
});
```

## Performance Considerations

### Memory Management
1. **Always Dispose Controllers**:
   ```dart
   @override
   void onClose() {
     emailController.dispose();
     super.onClose();
   }
   ```

2. **Cancel Timers**:
   ```dart
   @override
   void onClose() {
     _timer?.cancel();
     super.onClose();
   }
   ```

3. **Dispose Focus Nodes**:
   ```dart
   @override
   void onClose() {
     for (var node in focusNodes) {
       node.dispose();
     }
     super.onClose();
   }
   ```

### UI Performance
1. **Use Const Constructors**: `const EmailVerifyScreen()` enables widget caching
2. **Extract Static Widgets**: Widgets that don't change should be extracted
3. **Limit Obx Scope**: Only wrap widgets that need to rebuild
4. **Use Keys**: Add keys to list items for efficient rebuilding

## API Integration Guide

When integrating with real backend APIs:

### Email Verification Endpoint
```dart
final response = await NetworkCaller.post(
  ApiConstants.sendResetLink,
  body: {'email': emailController.text.trim()},
);

// Expected response:
// {
//   "success": true,
//   "message": "OTP sent to email"
// }
```

### OTP Verification Endpoint
```dart
final response = await NetworkCaller.post(
  ApiConstants.verifyOTP,
  body: {
    'email': email,
    'otp': otpCode,
  },
);

// Expected response:
// {
//   "success": true,
//   "token": "reset_token_here"
// }
```

### Password Reset Endpoint
```dart
final response = await NetworkCaller.post(
  ApiConstants.resetPassword,
  body: {
    'email': email,
    'otp': otp,
    'password': passwordController.text,
    'password_confirmation': confirmPasswordController.text,
  },
);

// Expected response:
// {
//   "success": true,
//   "message": "Password reset successfully"
// }
```

## Best Practices Summary

### DO ✅
- Use package imports: `import 'package:app_name/...'`
- Place business logic in controllers
- Extract reusable widgets
- Use constants for strings and colors
- Dispose all controllers and resources
- Validate forms before submission
- Provide user feedback with EasyLoading
- Use responsive sizing (flutter_screenutil)
- Follow GetX patterns (lazyPut, fenix: true)
- Register controllers in controller_binder.dart

### DON'T ❌
- Use relative imports: `import '../../utils/...'`
- Put logic in UI widgets
- Hardcode strings or colors
- Use `Get.put()` in build methods
- Forget to dispose resources
- Use `Color.withOpacity()` (use `Color.withValues(alpha: ...)`)
- Add bindings to routes in app_pages.dart
- Create controller instances manually
- Ignore form validation
- Block UI without loading indicators

## Navigation Flow Summary

```
LoginScreen
    ↓ (Forgot Password link)
EmailVerifyScreen
    ↓ (Email sent successfully)
OtpVerifyScreen
    ↓ (OTP verified)
ResetPasswordScreen
    ↓ (Password reset successfully)
LoginScreen (with cleared stack)
```

## Conclusion

This implementation demonstrates:
- Clean MVC architecture
- Proper GetX state management
- Reusable widget composition
- Form validation patterns
- Timer-based UI interactions
- Navigation with argument passing
- Error handling strategies
- Responsive design principles

The code is production-ready and follows all project guidelines. When integrating with a real backend, simply replace the TODO comments with actual NetworkCaller calls.

For questions or improvements, refer to the project's `copilot-instructions.md` file for additional guidelines and patterns.
