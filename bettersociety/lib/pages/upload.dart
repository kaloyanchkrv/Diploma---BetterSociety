import 'package:bettersociety/widgets/main_header.dart';
import 'package:flutter/material.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  buildSplashScreen() {
    return Scaffold(
      appBar: header(titleText: "Upload", removeBackButton: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(children: <Widget>[
            Container(
                padding: const EdgeInsets.fromLTRB(15, 110, 0, 0),
                alignment: Alignment.center,
                child: const Text("BetterSociety",
                    style:
                        TextStyle(fontSize: 40, fontWeight: FontWeight.bold)))
          ]),
          Container(
              padding: const EdgeInsets.only(top: 35, left: 20, right: 30),
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  SizedBox(
                      height: 40,
                      child: Material(
                          borderRadius: BorderRadius.circular(20),
                          shadowColor: Colors.greenAccent,
                          color: Colors.greenAccent,
                          elevation: 7,
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.of(context).pushNamed('/post');
                            },
                            child: const Center(
                              child: Text(
                                "Upload a new post",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ))),
                ],
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildSplashScreen();
  }
}
