import 'package:bettersociety/pages/achievements.dart';
import 'package:bettersociety/pages/create-account.dart';
import 'package:bettersociety/pages/create.post.dart';
import 'package:bettersociety/pages/edit-profile.dart';
import 'package:bettersociety/pages/home.dart';
import 'package:bettersociety/pages/login.dart';
import 'package:bettersociety/pages/profile.dart';
import 'package:bettersociety/pages/qr-screen.dart';
import 'package:bettersociety/pages/reset.dart';
import 'package:bettersociety/pages/settings.dart';
import 'package:bettersociety/pages/signup.dart';
import 'package:bettersociety/pages/upload.dart';
import 'package:bettersociety/pages/user-attending.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bettersociety/models/user.dart';

final usersRef = FirebaseFirestore.instance.collection('users');
final storageRef = FirebaseStorage.instance.ref();
final followersRef = FirebaseFirestore.instance.collection('followers');
final postsRef = FirebaseFirestore.instance.collection('posts');
final DateTime timestamp = DateTime.now();
UserModel? currentUser;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "BetterSociety",
        theme: ThemeData(
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const LoginPage(title: 'BetterSociety'),
        routes: <String, WidgetBuilder>{
          '/login': (BuildContext context) =>
              const LoginPage(title: 'BetterSociety'),
          '/signup': (BuildContext context) => const SignupPage(),
          '/reset': (BuildContext context) => const ResetPasswordPage(),
          '/home': (BuildContext context) => const HomePage(),
          '/post': (BuildContext context) =>
              CreatePostPage(currentUser: currentUser!),
          '/upload': (BuildContext context) => const UploadPage(),
          '/achievements': (BuildContext context) => const AchievementsPage(),
          '/edit-profile': (BuildContext context) =>
              EditProfilePage(currentUserId: currentUser?.id),
          '/profile': (BuildContext context) => ProfilePage(
                profileId: currentUser?.id,
              ),
          '/settings': (BuildContext context) => SettingsPage(),
          '/scanner': (BuildContext context) => const QrScannerScreen(),
          '/user-attend': (BuildContext context) => const AttendancePage(),
        });
  }
}
