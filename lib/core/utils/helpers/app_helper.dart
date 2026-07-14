import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class AppHelperFunctions{
  AppHelperFunctions._();

  /// Compresses an image to under 2 MB if it exceeds that size
  static Future<String> compressImageIfNeeded(String path) async {
    final file = File(path);
    if (!await file.exists()) return path;

    int size = await file.length();
    // 2 MB in bytes = 2097152
    const int maxBytes = 2 * 1024 * 1024;

    if (size <= maxBytes) {
      return path; // Already under 2 MB
    }

    try {
      final bytes = await file.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) return path;

      // Resize the image to maximum 1024 width/height maintaining aspect ratio
      img.Image resizedImage = decodedImage;
      if (decodedImage.width > 1024 || decodedImage.height > 1024) {
        resizedImage = img.copyResize(
          decodedImage,
          width: decodedImage.width > decodedImage.height ? 1024 : null,
          height: decodedImage.height >= decodedImage.width ? 1024 : null,
        );
      }

      // Encode as JPG with 70% quality
      final compressedBytes = img.encodeJpg(resizedImage, quality: 70);

      // Write to temp file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      return tempFile.path;
    } catch (e) {
      return path;
    }
  }
 static void showSnackBar(String message) {
  ScaffoldMessenger.of(Get.context!).showSnackBar(
   SnackBar(content: Text(message)),
  );
 }

 static void showAlert(String title, String message) {
  showDialog(
   context: Get.context!,
   builder: (BuildContext context) {
    return AlertDialog(
     title: Text(title),
     content: Text(message),
     actions: [
      TextButton(
       onPressed: () => Navigator.of(context).pop(),
       child: const Text('OK'),
      ),
     ],
    );
   },
  );
 }

 static void navigateToScreen(BuildContext context, Widget screen) {
  Navigator.push(
   context,
   MaterialPageRoute(builder: (_) => screen),
  );
 }

 static String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) {
   return text;
  } else {
   return '${text.substring(0, maxLength)}...';
  }
 }

 static bool isDarkMode(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
 }
 static Size screenSize() {
  return MediaQuery.of(Get.context!).size;
 }

 static double screenHeight() {
  return MediaQuery.of(Get.context!).size.height;
 }
 static double screenWidth() {
  return MediaQuery.of(Get.context!).size.width;
 }

 static String getFormattedDate(DateTime date, {String format = 'dd MMM yyyy'}) {
  return DateFormat(format).format(date);
 }

 static List<T> removeDuplicates<T>(List<T> list) {
  return list.toSet().toList();
 }

 static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
  final wrappedList = <Widget>[];
  for (var i = 0; i < widgets.length; i += rowSize) {
   final rowChildren = widgets.sublist(
    i,
    i + rowSize > widgets.length ? widgets.length : i + rowSize,
   );
   wrappedList.add(Row(children: rowChildren));
  }
  return wrappedList;
 }

}