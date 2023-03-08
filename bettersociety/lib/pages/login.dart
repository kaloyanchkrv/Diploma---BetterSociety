import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/user.dart';
import 'create_account.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool isAuth = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    final user = (await _auth
            .signInWithEmailAndPassword(
                email: _emailController.text.toString().trim(),
                password: _passwordController.text)
            .catchError((err) {}))
        .user;
    if (user != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {});
    }
  }

  createUserInFirestore() async {
    final account = _auth.currentUser;

    DocumentSnapshot doc = await usersRef.doc(account?.uid).get();

    if (!doc.exists) {
      // ignore: use_build_context_synchronously
      final username = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CreateAccountPage()));

      usersRef.doc(account?.uid).set({
        "id": account?.uid,
        "username": username,
        "email": account?.email,
        "bio": "",
        "photoUrl": "",
        "hasAttended": 0,
        "isGoingToAttend": {},
      });

      await followersRef
          .doc(currentUser!.id)
          .collection('userFollowers')
          .doc(currentUser!.id)
          .set({});

      doc = await usersRef.doc(account?.uid).get();
    }

    currentUser = UserModel.fromDocument(doc);
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
                alignment: Alignment.center,
                child: const Text("BetterSociety",
                    style:
                        TextStyle(fontSize: 40, fontWeight: FontWeight.bold)))
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
                        height: 20,
                      ),
                      TextFormField(
                        validator: (value) =>
                            value!.isEmpty ? 'Password can\'t be empty' : null,
                        controller: _passwordController,
                        decoration: const InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            )),
                        obscureText: true,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        alignment: const Alignment(1, 0),
                        padding: const EdgeInsets.only(top: 15, left: 20),
                        child: InkWell(
                          child: const Text(
                            'Forgot Password',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed('/reset');
                          },
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      SizedBox(
                          height: 40,
                          child: Material(
                              borderRadius: BorderRadius.circular(20),
                              shadowColor: Colors.black,
                              color: Colors.greenAccent,
                              elevation: 7,
                              child: GestureDetector(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await _login();
                                    // ignore: use_build_context_synchronously
                                    Navigator.of(context).pushNamed('/home');
                                  }
                                },
                                child: const Center(
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ))),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed('/signup');
                            },
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ))),
        ],
      ),
    );
  }
}
