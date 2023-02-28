// ignore_for_file: no_logic_in_create_state

import 'package:bettersociety/main.dart';
import 'package:bettersociety/widgets/main-header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  final String? postId;
  final String? postOwnerId;

  const AttendancePage({super.key, this.postId, this.postOwnerId});

  @override
  _AttendancePageState createState() => _AttendancePageState(
        postId: postId,
        postOwnerId: postOwnerId,
      );
}

class _AttendancePageState extends State<AttendancePage> {
  final String? postId;
  final String? postOwnerId;

  _AttendancePageState({required this.postId, required this.postOwnerId});

  buildUserAttendanceList() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        titleText: "Attendance",
      ),
      body: Column(children: <Widget>[
        Expanded(child: buildUserAttendanceList()),
        const Divider(),
      ]),
    );
  }
}

class UserAttend extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  const UserAttend({
    super.key,
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
  });

  factory UserAttend.fromDocument(DocumentSnapshot doc) {
    return UserAttend(
      username: doc['username'],
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
          ),
          subtitle: Text(username),
        ),
        const Divider(),
      ],
    );
  }
}
