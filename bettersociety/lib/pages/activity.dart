import 'package:bettersociety/widgets/progress-bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/main-header.dart';
import 'create.account.dart';

final usersRef = FirebaseFirestore.instance.collection('users');
final FirebaseAuth _auth = FirebaseAuth.instance;

class ActivityFeedPage extends StatefulWidget {
  @override
  _ActivityFeedPageState createState() => _ActivityFeedPageState();
}

class _ActivityFeedPageState extends State<ActivityFeedPage> {

  @override
  void initState() {
    super.initState();
  }

  createUser() {
     usersRef.doc().set({
      "username": "test",
      "isAdmin": false,
    });
  }

  updateUser() async {
    final doc = await usersRef.doc().get();
      if(doc.exists){
        doc.reference.update({
          "username": "test2",
          "isAdmin": false,
        });
      }
  }

  deleteUser() async {
    final doc = await usersRef.doc().get();
      if(doc.exists){
        doc.reference.delete();
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(isAppTitle: true),
        body: Text("Activity Feed Page"));
  }
}
