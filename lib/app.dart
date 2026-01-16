import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/profile_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Overthink Dump',
      theme: AppTheme.darkTheme,
      home: const ProfileScreen(), // 👤 ARTIK ANA EKRAN PROFİL
    );
  }
}
