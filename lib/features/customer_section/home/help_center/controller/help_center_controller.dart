import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Help Center Controller
/// Manages FAQ accordion states and support call functionality
class HelpCenterController extends GetxController {
  // Default support phone number
  static const String supportPhoneNumber = '+1234567890';

  // Observable list to track which FAQ items are expanded
  final RxList<int> expandedItems = <int>[0].obs;

  /// Toggle FAQ item expansion
  void toggleFaqItem(int index) {
    if (expandedItems.contains(index)) {
      expandedItems.remove(index);
    } else {
      expandedItems.add(index);
    }
  }

  /// Check if FAQ item is expanded
  bool isExpanded(int index) {
    return expandedItems.contains(index);
  }

  /// Call support with default phone number
  Future<void> callSupport() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: supportPhoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar(
          'Error',
          'Unable to make a phone call',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to launch phone dialer',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
