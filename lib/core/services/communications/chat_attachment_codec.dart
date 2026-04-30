import 'dart:io';

class ChatAttachmentPayload {
  const ChatAttachmentPayload({
    required this.mediaType,
    required this.mediaUrl,
    required this.fileName,
  });

  final String mediaType;
  final String mediaUrl;
  final String fileName;
}

class ChatAttachmentCodec {
  ChatAttachmentCodec._();

  static const int maxAttachmentBytes = 5 * 1024 * 1024;

  static Future<ChatAttachmentPayload?> fromPath({
    required String path,
    String? fileName,
  }) async {
    final normalizedPath = path.trim();
    if (normalizedPath.isEmpty) return null;

    final file = File(normalizedPath);
    if (!file.existsSync()) return null;
    final size = await file.length();
    if (size <= 0 || size > maxAttachmentBytes) return null;

    final resolvedFileName =
        fileName?.trim().isNotEmpty == true
        ? fileName!.trim()
        : normalizedPath.split(Platform.pathSeparator).last;
    final extension = _extractExtension(resolvedFileName);
    final mediaType = _mediaTypeForExtension(extension);

    return ChatAttachmentPayload(
      mediaType: mediaType,
      mediaUrl: normalizedPath,
      fileName: resolvedFileName,
    );
  }

  static String maxSizeLabel() {
    return '${(maxAttachmentBytes / (1024 * 1024)).round()}MB';
  }

  static String _extractExtension(String fileName) {
    final normalized = fileName.trim();
    final dotIndex = normalized.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == normalized.length - 1) return '';
    return normalized.substring(dotIndex + 1).toLowerCase();
  }

  static String _mediaTypeForExtension(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image';
      case 'png':
        return 'image';
      case 'gif':
        return 'image';
      case 'webp':
        return 'image';
      case 'bmp':
        return 'image';
      case 'heic':
        return 'image';
      default:
        return 'file';
    }
  }
}
