import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:outdoorda_flutter/core/common/widgets/custom_text_field.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/features/installer_section/message_section/controllers/messaging_controller.dart';
import 'package:outdoorda_flutter/features/installer_section/message_section/models/message.dart';
import 'package:outdoorda_flutter/features/installer_section/message_section/views/widgets/chat_bubble_widget.dart';

/// Messaging/Chat screen for one-on-one conversations
/// Displays chat messages with send/receive bubbles and message input
class InstallerConversationScreen extends StatelessWidget {
  const InstallerConversationScreen({super.key});

  static const List<String> _quickReactions = <String>[
    '👍',
    '❤️',
    '😂',
    '😮',
    '😢',
    '🙏',
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InstallerMessagingController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textDark, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            // User avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Image.network(
                controller.conversation.userAvatar,
                width: 40.w,
                height: 40.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.gradientStart,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Center(
                      child: Text(
                        controller.conversation.userName.isNotEmpty
                            ? controller.conversation.userName[0].toUpperCase()
                            : '?',
                        style: figtreeTextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cardBackgroundWhite,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),

            // User name
            Expanded(
              child: Text(
                controller.conversation.userName,
                style: figtreeTextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.gradientEnd,
                  ),
                );
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet',
                    style: figtreeTextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final formattedTime = controller.formatMessageTime(
                    message.timestamp,
                  );
                  return InstallerChatBubbleWidget(
                    message: message,
                    formattedTime: formattedTime,
                    onDoubleTap: () =>
                        _showReactionPicker(context, controller, message),
                    onLongPress: () =>
                        _showMessageActions(context, controller, message),
                  );
                },
              );
            }),
          ),

          // Message input
          Padding(
            padding: EdgeInsets.only(left: 14.h, right: 16.h, bottom: 24.h),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    prefixIconOnPressed: controller.onCameraPressed,
                    prefixIcon: Iconsax.camera_copy,
                    controller: controller.messageController,
                    // obscureText: true,
                    placeholder: 'Type your message here...',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.r),
                  child: Card(
                    // margin: EdgeInsets.only(left: 21.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    color: Colors.white,
                    child: IconButton(
                      onPressed: () {
                        controller.sendMessage();
                      },
                      icon: Icon(
                        Iconsax.send_2_copy,
                        size: 26.r,
                        color: AppColors.gradientEnd,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showReactionPicker(
    BuildContext context,
    InstallerMessagingController controller,
    Message message,
  ) async {
    if (message.isSentByMe || message.isDeleted) return;
    final messageId = message.id.trim();
    if (messageId.isEmpty) return;

    final reaction = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            child: Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: _quickReactions.map((emoji) {
                return InkWell(
                  onTap: () => Navigator.of(context).pop(emoji),
                  borderRadius: BorderRadius.circular(999.r),
                  child: Container(
                    width: 48.w,
                    height: 48.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6F8),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(emoji, style: TextStyle(fontSize: 22.sp)),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (!context.mounted) return;
    if (reaction == null || reaction.trim().isEmpty) return;
    await controller.reactToMessage(messageId: messageId, reaction: reaction);
  }

  Future<void> _showMessageActions(
    BuildContext context,
    InstallerMessagingController controller,
    Message message,
  ) async {
    if (!message.isSentByMe || message.isDeleted) return;
    if (message.id.trim().isEmpty || message.id.startsWith('local_')) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () => Navigator.of(context).pop('edit'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => Navigator.of(context).pop('delete'),
              ),
            ],
          ),
        );
      },
    );

    if (!context.mounted) return;
    if (action == 'edit') {
      await _showEditDialog(context, controller, message);
    } else if (action == 'delete') {
      await controller.deleteMessage(messageId: message.id);
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    InstallerMessagingController controller,
    Message message,
  ) async {
    final textController = TextEditingController(text: message.message);

    final newText = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit message'),
          content: TextField(
            controller: textController,
            autofocus: true,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Type your message'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(textController.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newText == null || newText.trim().isEmpty) return;
    if (newText.trim() == message.message.trim()) return;
    await controller.editMessage(messageId: message.id, newText: newText);
  }
}
