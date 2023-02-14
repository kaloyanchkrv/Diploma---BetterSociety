import 'package:bettersociety/widgets/main-header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AchievementsPage extends StatefulWidget {
  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(titleText: "Achievements", removeBackButton: false),
        body: Text("Achievements Page"));
  }
}

