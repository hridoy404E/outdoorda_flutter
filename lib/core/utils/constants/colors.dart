// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Authentication Screen Colors (Figma Design)
  static const Color neutral800 = Color(0xFF272F3A); // Headings
  static const Color neutral700 = Color(0xFF323C4B); // Body text
  static const Color neutral300 = Color(
    0xFF848D9B,
  ); // Inactive tabs/secondary text
  static const Color blackText = Color(0xFF333333);
  static const Color blackTextSecondary = Color(0xFF767676);
  static const Color neutral25 = Color(0xFFFFFFFF); // White
  static const Color bg = Color(0xFFEBE8E3); // Auth screens background
  static const Color borderColor = Color(0xFFEFEEEE); // Input borders

  // Gradient Colors for Buttons and Tabs
  static const Color gradientStart = Color(0xFF6FAACC); // Blue gradient start
  static const Color gradientEnd = Color(0xFF395C70); // Blue gradient end

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
  );

  // Utility Colors
  static const Color success = Color(0xFF4CAF50); // Green for success messages
  static const Color warning = Color(0xFFFFA726); // Orange for warnings
  static const Color error = Color(0xFFF44336); // Red for error messages
  // static const Color info = Color(
  //   0xFF29B6F6,
  // ); // Blue for informational messages

  // Service Request Screen Colors (100% Figma Match)
  // Ongoing Badge Gradient: Purple
  static const Color ongoingBadgeStart = Color(0xFF7A42FE); // Figma: #7a42fe
  static const Color ongoingBadgeEnd = Color(0xFF9900FF); // Figma: #9900ff

  // Installer Assigned Badge Gradient: Blue
  static const Color installerAssignedStart = Color(
    0xFF429AFE,
  ); // Figma: #429afe
  static const Color installerAssignedEnd = Color(0xFF006FFF); // Figma: #006fff

  // Receiving Bids Badge Gradient: Orange
  static const Color receivingBidsStart = Color(0xFFFEA642); // Figma: #fea642
  static const Color receivingBidsEnd = Color(0xFFFF6A00); // Figma: #ff6a00

  // Completed Badge: Green (keep existing for completed status)
  static const Color completedBadge = Color(0xFF22C55E);

  // Assigned Badge Gradient: Green (from Figma #11d000 to #0c5302)
  static const Color assignedBadgeStart = Color(0xFF11D000); // Figma: #11d000
  static const Color assignedBadgeEnd = Color(0xFF0C5302); // Figma: #0c5302

  // In Progress Badge: Blue (same as Installer Assigned)
  static const Color inProgressBadgeStart = Color(0xFF429AFE); // Figma: #429afe
  static const Color inProgressBadgeEnd = Color(0xFF006FFF); // Figma: #006fff

  // KPI Metrics Card Background (from Figma #f2faff)
  static const Color kpiCardBackground = Color(0xFFF2FAFF); // Figma: #f2faff

  // Text Colors from Figma
  static const Color textDark = Color(0xFF2B4554); // Foundation/Blue/Dark
  static const Color textNormal = Color(0xFF395C70); // Foundation/Blue/Normal
  static const Color textSecondary = Color(0xFF6C7787); // Neutral/400
  static const Color textTertiary = Color(0xFF848D9B); // Neutral/300

  // Card & Background Colors from Figma
  static const Color cardBackground = Color(
    0xFFEBEFF1,
  ); // Foundation/Blue/Light
  static const Color cardBorder = Color(
    0xFFC2CCD3,
  ); // Foundation/Blue/Light:active
  static const Color cardBackgroundWhite = Color(
    0xFFFFFFFF,
  ); // White for installer card
  static const Color dividerColor = Color(0xFFC2CCD3); // Same as card border

  // Ongoing Card Gradient from Figma
  static const Color ongoingCardGradientStart = Color(
    0xFF6FAACC,
  ); // Figma: #6faacc
  static const Color ongoingCardGradientEnd = Color(
    0xFF395C70,
  ); // Figma: #395c70

  // Price/Sky Color from Figma
  static const Color priceColor = Color(0xFF609CBF); // Foundation/Sky/Dark

  // Icon/Action Colors from Figma
  static const Color iconColor = Color(0xFF395C70); // Same as text normal

  // Star Rating from Figma
  static const Color starYellow = Color(0xFFFBBC05); // Yellow for star ratings

  // Messaging Screen Colors from Figma
  static const Color messageBubbleSent = Color(
    0xFF395C70,
  ); // Sent message bubble background
  static const Color messageBubbleReceived = Color(
    0xFFEBEFF1,
  ); // Received message bubble background
  static const Color messageBubbleReceivedText = Color(
    0xFF1E242C,
  ); // Neutral/900 for received message text
  static const Color messageBubbleSentText = Color(
    0xFFFFFFFF,
  ); // White for sent message text
  static const Color timestampSent = Color(
    0xFFEFEEEE,
  ); // Timestamp for sent messages
  static const Color timestampReceived = Color(
    0xFFC6CAD1,
  ); // Timestamp for received messages
  static const Color messageInputBackground = Color(
    0xFFF9FAFB,
  ); // Message input field background
  static const Color messageInputBorder = Color(
    0xFFDFE1E6,
  ); // Message input field border
  static const Color messageInputPlaceholder = Color(
    0xFF848D9B,
  ); // Placeholder text color
  static const Color unreadBadgeGradientStart = Color(
    0xFF6FAACC,
  ); // Unread count badge gradient start
  static const Color unreadBadgeGradientEnd = Color(
    0xFF395C70,
  ); // Unread count badge gradient end
  static const Color unreadBadgeText = Color(
    0xFFFFFFFF,
  ); // White text on unread badge
  static const Color messageListTime = Color(
    0xFF848D9B,
  ); // Neutral/300 for time in message list
  static const Color messageListPreview = Color(
    0xFF848D9B,
  ); // Preview text in message list

  // Settings Screen Colors from Figma
  static const Color settingsBg = Color(0xFFEBE8E3); // Settings background
  static const Color settingsCardBg = Color(0xFFEBEFF1); // Card background
  static const Color settingsPetCardBg = Color(
    0xFFE1E7EA,
  ); // Pet card background
  static const Color settingsBorderSky = Color(
    0xFF4D7D99,
  ); // Border/button color
  static const Color settingsTextPrimary = Color(0xFF1E242C); // Neutral/900
  static const Color settingsTextSecondary = Color(0xFF6C7787); // Neutral/400
  static const Color settingsTextTitle = Color(0xFF2B4554); // Title text
  static const Color settingsIconEdit = Color(0xFF848D9B); // Edit icon color
  static const Color settingsWhite = Color(0xFFFFFFFF); // White backgrounds
  static const Color settingsLogoutBg = Color(0xFFFFE9E9); // Logout button bg
  static const Color settingsLogoutText = Color(0xFFFF383C); // Logout text
  static const Color settingsLogoutBorder = Color(
    0x24FF383C,
  ); // Logout border rgba(255, 56, 60, 0.14)

  // Create New Job Bottom Sheet Colors from Figma
  static const Color neutral900 = Color(0xFF1E242C); // Heading text
  static const Color textColor = Color(0xFF333333); // Label text
  static const Color secondary500 = Color(0xFF1A1C1E); // Input text
  static const Color neutral400 = Color(0xFF6C7787); // Description text
  static const Color inputBorderColor = Color(0xFFEDF1F3); // Input border
  static const Color cardBackgroundHover = Color(
    0xFFE1E7EA,
  ); // Installer card hover
  static const Color skyDark = Color(0xFF4D7D99); // Back button border/text
  static const Color uploadBorderGreen = Color(0xFF11D000); // Upload button
  static const Color uploadGradientEnd = Color(0xFF0C5302); // Upload gradient
  static const Color checkboxBorder = Color(0xFFD0D5DD); // Unchecked checkbox
}
