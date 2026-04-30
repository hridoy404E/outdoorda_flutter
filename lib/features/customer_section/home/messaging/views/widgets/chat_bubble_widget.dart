import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'package:outdoorda_flutter/core/utils/constants/app_strings.dart';
import 'package:outdoorda_flutter/core/common/styles/global_text_style.dart';
import 'package:outdoorda_flutter/features/customer_section/home/messaging/models/message.dart';

/// Reusable widget for displaying chat message bubbles
/// Shows different styles for sent vs received messages
class ChatBubbleWidget extends StatelessWidget {
  const ChatBubbleWidget({
    super.key,
    required this.message,
    required this.formattedTime,
    this.onDoubleTap,
    this.onLongPress,
  });

  final Message message;
  final String formattedTime;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final displayText = message.isDeleted
        ? AppStrings.messageDeleted
        : message.message;
    final mediaUrl = message.mediaUrl?.trim();
    final hasMedia = !message.isDeleted && (mediaUrl?.isNotEmpty ?? false);
    final isImageMedia = hasMedia && message.mediaType?.toLowerCase() == 'image';
    final reactionsSummary = _buildReactionsSummary(message.reactions);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: message.isSentByMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Message bubble + stacked reaction badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 280.w),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: message.isSentByMe
                        ? AppColors.messageBubbleSent
                        : AppColors.messageBubbleReceived,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: message.isSentByMe
                          ? Radius.circular(16.r)
                          : Radius.zero,
                      bottomRight: message.isSentByMe
                          ? Radius.zero
                          : Radius.circular(16.r),
                    ),
                    border: message.isSentByMe
                        ? null
                        : Border.all(
                            color: AppColors.cardBorder.withValues(alpha: 0.3),
                            width: 1,
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasMedia && isImageMedia) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: _buildImagePreview(mediaUrl!),
                        ),
                        SizedBox(height: displayText.trim().isEmpty ? 0 : 8.h),
                      ],
                      if (hasMedia && !isImageMedia) ...[
                        _buildFilePreview(message.mediaType),
                        SizedBox(height: displayText.trim().isEmpty ? 0 : 8.h),
                      ],
                      if (displayText.trim().isNotEmpty)
                        Text(
                          displayText,
                          style: figtreeTextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: message.isSentByMe
                                ? AppColors.messageBubbleSentText
                                : AppColors.messageBubbleReceivedText,
                            lineHeight: 1.4,
                          ),
                        ),
                    ],
                  ),
                ),
                if (reactionsSummary != null)
                  Positioned(
                    bottom: -11.h,
                    right: message.isSentByMe ? 10.w : null,
                    left: message.isSentByMe ? null : 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(
                          color: AppColors.cardBorder.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        reactionsSummary,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: montserratTextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: reactionsSummary != null ? 15.h : 4.h),

            // Timestamp
            Text(
              message.editedAt != null
                  ? '$formattedTime · edited'
                  : formattedTime,
              style: montserratTextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: message.isSentByMe
                    ? AppColors.textSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _buildReactionsSummary(Map<String, dynamic> reactions) {
    if (reactions.isEmpty) return null;

    final parts = <String>[];
    reactions.forEach((key, value) {
      if (key.trim().isEmpty) return;
      final count = value is int
          ? value
          : value is num
          ? value.toInt()
          : value is List
          ? value.length
          : 0;
      if (count <= 0) return;
      parts.add('$key $count');
    });

    if (parts.isEmpty) return null;
    return parts.join('   ');
  }

  Widget _buildImagePreview(String mediaUrl) {
    final imageBytes = _decodeDataImage(mediaUrl);
    if (imageBytes != null) {
      return Image.memory(
        imageBytes,
        width: 220.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildMediaErrorFallback();
        },
      );
    }

    final localPath = _extractLocalPath(mediaUrl);
    if (localPath != null) {
      final file = File(localPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 220.w,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildMediaErrorFallback();
          },
        );
      }
    }

    return Image.network(
      mediaUrl,
      width: 220.w,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildMediaErrorFallback();
      },
    );
  }

  Uint8List? _decodeDataImage(String mediaUrl) {
    if (!mediaUrl.startsWith('data:image')) return null;
    final commaIndex = mediaUrl.indexOf(',');
    if (commaIndex <= 0 || commaIndex >= mediaUrl.length - 1) return null;
    final encoded = mediaUrl.substring(commaIndex + 1);
    try {
      return base64Decode(encoded);
    } catch (_) {
      return null;
    }
  }

  String? _extractLocalPath(String mediaUrl) {
    final normalized = mediaUrl.trim();
    if (normalized.startsWith('file://')) {
      final path = normalized.substring('file://'.length);
      return path.isEmpty ? null : path;
    }
    if (normalized.startsWith('/')) return normalized;
    return null;
  }

  Widget _buildFilePreview(String? mediaType) {
    final label = (mediaType?.trim().isNotEmpty ?? false)
        ? '${mediaType!.toUpperCase()} attachment'
        : 'File attachment';
    return Container(
      width: 220.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_file_outlined,
            size: 18.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: montserratTextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaErrorFallback() {
    return Container(
      width: 220.w,
      height: 120.h,
      color: Colors.black12,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined),
    );
  }
}
