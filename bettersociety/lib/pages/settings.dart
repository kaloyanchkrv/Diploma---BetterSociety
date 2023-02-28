import 'package:bettersociety/main.dart';
import 'package:bettersociety/widgets/main-header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final String postId;
  final qrData = FirebaseAuth.instance.currentUser!.uid;
  final qrKey = GlobalKey();
  late final int attendance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header(titleText: "My Code", removeBackButton: false),
        body: Column(
          children: [
            Center(
              key: qrKey,
              child: QrImage(
                data: qrData,
                size: 250,
                backgroundColor: Colors.white,
                version: QrVersions.auto,
              ),
            ),
          ],
        ));
  }
}
