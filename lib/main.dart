import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const GPSTrackerApp());
}

class GPSTrackerApp extends StatelessWidget {
  const GPSTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS TRAKER KITA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: Colors.redAccent,
      ),
      home: const SplashScreen(),
    );
  }
}
