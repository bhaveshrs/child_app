import 'package:child_app/child_app.dart';
import 'package:child_app/helper/app_binding.dart';
import 'package:child_app/helper/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: AppBinding(),
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: AppColors.mainColor),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
