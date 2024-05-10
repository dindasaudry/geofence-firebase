import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:geofencefirebase/features/app/splash_screen/splash_screen.dart';
import 'package:geofencefirebase/features/user_auth/presentation/pages/home_page.dart';
import 'package:geofencefirebase/features/user_auth/presentation/pages/login_page.dart';
import 'package:geofencefirebase/features/user_auth/presentation/pages/sign_up_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyASKC9VYj5Q-uocTPN829XnBZGmRq0eCG4",
        appId: "1:615093795725:web:99762eda8ddd3d57fb5bc4",
        messagingSenderId: "615093795725",
        projectId: "geofence2-app",
        // Your web Firebase config options
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase',
      routes: {
        '/': (context) => SplashScreen(
          // Here, you can decide whether to show the LoginPage or HomePage based on user authentication
          child: LoginPage(),
        ),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}