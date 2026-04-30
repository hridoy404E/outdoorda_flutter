import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle figtreeTextStyle({
  double fontSize = 14.0,
  FontWeight fontWeight = FontWeight.w400,
  double lineHeight = 0.0,
  TextAlign textAlign = TextAlign.center,
  Color color = Colors.black,
}) {
  return GoogleFonts.figtree(
    fontSize: fontSize.sp,
    fontWeight: fontWeight,
    height: lineHeight.sp,
    color: color,
  );
}

TextStyle interTextStyle({
  double fontSize = 14.0,
  FontWeight fontWeight = FontWeight.w400,
  double lineHeight = 0.0,
  TextAlign textAlign = TextAlign.center,
  Color color = Colors.black,
}) {
  return GoogleFonts.inter(
    fontSize: fontSize.sp,
    fontWeight: fontWeight,
    height: lineHeight.sp,
    color: color,
  );
}

TextStyle poppinsTextStyle({
  double fontSize = 14.0,
  FontWeight fontWeight = FontWeight.w400,
  double lineHeight = 0.0,
  TextAlign textAlign = TextAlign.center,
  Color color = Colors.black,
}) {
  return GoogleFonts.poppins(
    fontSize: fontSize.sp,
    fontWeight: fontWeight,
    height: lineHeight.sp,
    color: color,
  );
}

TextStyle montserratTextStyle({
  double fontSize = 14.0,
  FontWeight fontWeight = FontWeight.w400,
  double lineHeight = 0.0,
  TextAlign textAlign = TextAlign.center,
  Color color = Colors.black,
}) {
  return GoogleFonts.montserrat(
    fontSize: fontSize.sp,
    fontWeight: fontWeight,
    height: lineHeight.sp,
    color: color,
  );
}
