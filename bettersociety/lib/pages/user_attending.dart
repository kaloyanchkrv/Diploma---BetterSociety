// ignore_for_file: no_logic_in_create_state

import 'dart:ffi';

import 'package:bettersociety/main.dart';
import 'package:bettersociety/models/user.dart';
import 'package:bettersociety/widgets/main_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/progress_bar.dart';

class AttendancePage extends StatefulWidget {
  final String postId;
  final String postOwnerId;

  const AttendancePage(
      {super.key, required this.postId, required this.postOwnerId});

  @override
  AttendancePageState createState() => AttendancePageState(
        postId: postId,
        postOwnerId: postOwnerId,
      );
}

class AttendancePageState extends State<AttendancePage> {
  final String postId;
  final String postOwnerId;
  final auth = FirebaseAuth.instance;

  AttendancePageState({required this.postId, required this.postOwnerId});

  buildUsers() {
    return StreamBuilder(
      stream:
          attendanceRef.doc(postId).collection('userAttendance').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserAttendance> users = [];
        snapshot.data!.docs.forEach((doc) {
          users.add(UserAttendance.fromDocument(doc));
        });
        return ListView(
          children: users,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        titleText: 'Attendance',
        removeBackButton: false,
      ),
      body: Column(children: <Widget>[
        Expanded(child: buildUsers()),
        const Divider(),
      ]),
    );
  }
}

class UserAttendance extends StatelessWidget {
  final String username;
  final String userId;
  final String? avatarUrl;
  final bool isAttending;
  final Timestamp timestamp;

  const UserAttendance({
    super.key,
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.isAttending,
    required this.timestamp,
  });

  factory UserAttendance.fromDocument(DocumentSnapshot doc) {
    return UserAttendance(
      username: doc['username'],
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      isAttending: doc['isAttending'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(isAttending ? 'Attending' : 'Not Attending'),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl ?? ''),
          ),
          subtitle: Text(username),
        ),
        const Divider(),
      ],
    );
  }
}
