// ignore_for_file: prefer_const_constructors
import 'dart:io';
import 'package:bettersociety/pages/activity.dart';
import 'package:bettersociety/pages/create.account.dart';
import 'package:bettersociety/pages/create.post.dart';
import 'package:bettersociety/pages/home.dart';
import 'package:bettersociety/pages/reset.dart';
import 'package:bettersociety/pages/signup.dart';
import 'package:bettersociety/pages/upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bettersociety/models/user.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final usersRef = FirebaseFirestore.instance.collection('users');
final DateTime timestamp = DateTime.now();
UserModel? currentUser;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "BetterSociety",
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const LoginPage(title: 'BetterSociety'),
        routes: <String, WidgetBuilder>{
          '/login': (BuildContext context) =>
              new LoginPage(title: 'BetterSociety'),
          '/signup': (BuildContext context) => new SignupPage(),
          '/reset': (BuildContext context) => new ResetPasswordPage(),
          '/home': (BuildContext context) => new HomePage(),
          '/post': (BuildContext context) => new CreatePostPage(),
          '/upload': (BuildContext context) => new UploadPage(),
        });
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _success = 1;
  String _userEmail = "";
  bool isAuth = false;
  final _formKey = GlobalKey<FormState>();


  Future<void> _login() async {
    final user = (await _auth
            .signInWithEmailAndPassword(
                email: _emailController.text.toString().trim(),
                password: _passwordController.text)
            .catchError((err) {
      print(err);
    }))
        .user;
    if (user != null) {
      setState(() {
        _success = 2;
        _userEmail = user.email!;
        isAuth = true;
      });
    } else {
      setState(() {
        _success = 3;
      });
    }

    createUserInFirestore();
  }

  createUserInFirestore() async {
    final account = _auth.currentUser;

    DocumentSnapshot doc = await usersRef.doc(account!.uid).get();

    if (!doc.exists) {
      final username = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => new CreateAccountPage()));

      usersRef.doc(account.uid).set({
        "id": account.uid,
        "username": username,
        "email": account.email,
        "bio": "",
        "photoUrl": "",
      });

      doc = await usersRef.doc(account.uid).get();
    }

    currentUser = UserModel.fromDocument(doc);
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
                alignment: Alignment.center,
                child: const Text("BetterSociety",
                    style:
                        TextStyle(fontSize: 40, fontWeight: FontWeight.bold)))
          ])),
          Container(
            padding: EdgeInsets.only(top: 35, left: 20, right: 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    validator: (value) => value!.isEmpty ? 'Email can\'t be empty' : null,
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
                    height: 20,
                  ),
                  TextFormField(
                    validator: (value) => value!.isEmpty ? 'Password can\'t be empty' : null,
                    controller: _passwordController,
                    decoration: InputDecoration(
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
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    alignment: Alignment(1, 0),
                    padding: EdgeInsets.only(top: 15, left: 20),
                    child: InkWell(
                      child: Text(
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
                  SizedBox(
                    height: 40,
                  ),
                  Container(
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
                  SizedBox(
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
