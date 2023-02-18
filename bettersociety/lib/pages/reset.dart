import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final firebaseAuth = FirebaseAuth.instance;

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final int _success = 1;
  final String _userEmail = "";
  final _formKey = GlobalKey<FormState>();

  void _resetPassword() async {
    await firebaseAuth.sendPasswordResetEmail(email: _emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          Stack(children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(15, 110, 0, 0),
              child: const Text(
                "Forgot Password",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            )
          ]),
          Container(
              padding: const EdgeInsets.only(top: 35, left: 20, right: 30),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        validator: (value) =>
                            value!.isEmpty ? 'Email can\'t be empty' : null,
                        controller: _emailController,
                        decoration: const InputDecoration(
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
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ))),
          Container(
              height: 40,
              margin: const EdgeInsets.only(left: 25, right: 25),
              child: Material(
                  borderRadius: BorderRadius.circular(20),
                  shadowColor: Colors.black,
                  color: Colors.greenAccent,
                  child: GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        _resetPassword();
                        Navigator.pop(context);
                      }
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
              )),
        ]));
  }
}
