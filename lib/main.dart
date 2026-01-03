import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'firebase_options.dart'; // Import file yang digenerate langkah 3
import 'splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GPSTrackerApp());
}

class GPSTrackerApp extends StatelessWidget {
  const GPSTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS TRACKER KITA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: Colors.redAccent,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}