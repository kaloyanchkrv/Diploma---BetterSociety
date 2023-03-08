import 'package:bettersociety/main.dart';
import 'package:bettersociety/pages/activity.dart';
import 'package:bettersociety/pages/profile.dart';
import 'package:bettersociety/pages/search.dart';
import 'package:bettersociety/pages/timeline.dart';
import 'package:bettersociety/pages/upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  logout() {
    firebaseAuth.signOut();
    Navigator.pushNamed(context, '/login');
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          TimelinePage(currentUser: currentUser),
          const ActivityFeedPage(),
          const UploadPage(),
          const SearchPage(),
          ProfilePage(profileId: currentUser!.id),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Colors.greenAccent,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active_outlined)),
          BottomNavigationBarItem(icon: Icon(Icons.library_add, size: 35)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }
}
