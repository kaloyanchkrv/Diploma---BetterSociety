import 'package:bettersociety/widgets/main-header.dart';
import 'package:flutter/material.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header(titleText: "Achievements", removeBackButton: false),
        body: const Text("Achievements Page"));
  }
}
