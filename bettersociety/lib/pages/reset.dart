// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final firebaseAuth = FirebaseAuth.instance;

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {

   final TextEditingController _emailController = TextEditingController();
   int _success = 1;
   String _userEmail = "";

   void _resetPassword() async {
      await firebaseAuth.sendPasswordResetEmail(email: _emailController.text);
     }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          Container(
              child: Stack(children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(15, 110, 0, 0),
              child: const Text(
                "Forgot Password",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            )
          ]
          )
          ),
          Container(
              padding: EdgeInsets.only(top: 35, left: 20, right: 30),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        )),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              )),
              Container(
                      height: 40,
                      child: Material(
                          borderRadius: BorderRadius.circular(20),
                          shadowColor: Colors.greenAccent,
                          color: Colors.black,
                          elevation: 7,
                          child: GestureDetector(
                            onTap: () {
                              _resetPassword();
                              Navigator.pop(context);
                            },
                            child: const Center(
                              child: Text(
                                "Reset Password",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ))),
                          Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _success == 1
                          ? ''
                          : (_success == 2
                          ? 'Successfully sent reset password email to  $_userEmail'
                          : 'Email not sent'),
                      style: const TextStyle(color: Colors.red),
                    )
                    ),
        ]
        )
        );
  }
}
