import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:outdoorda_flutter/core/utils/constants/colors.dart';
import 'core/bindings/controller_binder.dart';
import 'routes/app_routes.dart';

class Outdoorda extends StatelessWidget {
  const Outdoorda({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoute.getSplashScreen(),
          getPages: AppRoute.routes,
          initialBinding: ControllerBinder(),
          themeMode: ThemeMode.light,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.bg,
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          // darkTheme: AppTheme.darkTheme,
          builder: (context, widget) {
            widget = EasyLoading.init()(context, widget);
            final mediaQueryData = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQueryData.copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: widget,
            );
          },
        );
      },
    );
  }
}
