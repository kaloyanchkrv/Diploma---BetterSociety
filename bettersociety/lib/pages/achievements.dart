// ignore_for_file: unused_local_variable, unrelated_type_equality_checks

import 'package:bettersociety/widgets/main-header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/user.dart';
import '../widgets/progress-bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AchievementsPage extends StatefulWidget {
  final String? postId;
  const AchievementsPage({super.key, this.postId});

  @override
  _AchievementsPageState createState() =>
      _AchievementsPageState(postId: postId);
}

Future<Widget> getAchievements() async {
  final user = usersRef.doc(currentUser!.id);
  final doc = await user.get();
  final data = doc.data();
  int attendance = 0;
  if (data != null) {
    attendance = data['hasAttended'];
  }

  print(attendance);

  if (attendance == 0) {
    return Column(
      children: const [
        Center(
          child: Text("You have not attended any events yet",
              style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
        )
      ],
    );
  }

  if (attendance == 1) {
    return Column(
      children: [
        Center(
          child: SvgPicture.asset(
            'assets/images/bronze-medal.svg',
            height: 150,
            width: 150,
          ),
        ),
        const Text('Bronze Medal'),
        const Text("You've attended 1 event!"),
      ],
    );
  }
  if (attendance >= 5 && attendance < 10) {
    return Column(
      children: [
        Center(
          child: SvgPicture.asset(
            'assets/images/silver-medal.svg',
            height: 150,
            width: 150,
          ),
        ),
        const Text('Silver Medal'),
        const Text("You've attended 5 events!"),
      ],
    );
  }

  if (attendance >= 10) {
    return Column(
      children: [
        Center(
          child: SvgPicture.asset(
            'assets/images/gold-medal.svg',
            height: 150,
            width: 150,
          ),
        ),
        const Text('Gold Medal'),
        const Text("You've attended 10 events!"),
      ],
    );
  }

  return SizedBox();
}

buildAchievements() {
  return FutureBuilder(
    future: getAchievements(),
    builder: (context, AsyncSnapshot snapshot) {
      if (!snapshot.hasData) {
        return circularProgress();
      }
      return snapshot.data;
    },
  );
}

class _AchievementsPageState extends State<AchievementsPage> {
  int hasAchieved = 0;
  int attendanceCount = 0;
  final String currentUserId = currentUser!.id;
  final String? postId;

  _AchievementsPageState({required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header(titleText: "Achievements", removeBackButton: false),
        body: Column(
          children: <Widget>[
            buildAchievements(),
          ],
        ));
  }
}
