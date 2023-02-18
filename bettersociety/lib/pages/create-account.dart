import 'dart:async';

import 'package:bettersociety/widgets/main-header.dart';
import 'package:flutter/material.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String username = "";

  submit() {
    final form = _formKey.currentState;
    if (form != null) {
      if (form.validate()) {
        if (_formKey.currentState != null) {
          form.save();
          final SnackBar snackbar =
              SnackBar(content: Text("Welcome $username!"));
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
          Timer(const Duration(seconds: 2), () {
            Navigator.pop(context, username);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar:
            Header(titleText: "Set up your profile", removeBackButton: true),
        body: ListView(children: <Widget>[
          Container(
            child: Column(children: <Widget>[
              const Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Center(
                    child: Text("Set your username",
                        style: TextStyle(
                          fontSize: 25,
                        )),
                  )),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    validator: (val) {
                      if (val!.trim().length < 3 || val.isEmpty) {
                        return "Username too short";
                      }
                      return null;
                    },
                    onSaved: (val) => username = val!,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                      labelStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      hintText: "Username must be at least 3 characters long",
                    ),
                  ),
                ),
              ),
              GestureDetector(
                  onTap: submit,
                  child: Container(
                      height: 50,
                      width: 350,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                          child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Montserrat",
                        ),
                      ))))
            ]),
          )
        ]));
  }
}
