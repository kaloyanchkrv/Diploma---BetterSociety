// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:developer';

import 'package:bettersociety/pages/activity.dart';
import 'package:bettersociety/pages/profile.dart';
import 'package:bettersociety/pages/search.dart';
import 'package:bettersociety/pages/upload.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final firebaseAuth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
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
    initialPage: 2;
  }

  _logout() {
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

  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
      children: <Widget>[
        ActivityFeedPage(),
        UploadPage(),
        SearchPage(),
        ProfilePage(),
      ],
      controller: pageController,
      onPageChanged: onPageChanged,
      physics: NeverScrollableScrollPhysics(),
    ),
    bottomNavigationBar: CupertinoTabBar(
      currentIndex: pageIndex,
      onTap: onTap,
      activeColor: Theme.of(context).primaryColor,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
        BottomNavigationBarItem(icon: Icon(Icons.library_add, size: 35)),
        BottomNavigationBarItem(icon: Icon(Icons.search)),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
      ],
    ),
    ); 
  }
}
