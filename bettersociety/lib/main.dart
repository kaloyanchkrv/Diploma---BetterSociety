import 'package:bettersociety/pages/achievements.dart';
import 'package:bettersociety/pages/create-account.dart';
import 'package:bettersociety/pages/create.post.dart';
import 'package:bettersociety/pages/edit-profile.dart';
import 'package:bettersociety/pages/home.dart';
import 'package:bettersociety/pages/profile.dart';
import 'package:bettersociety/pages/reset.dart';
import 'package:bettersociety/pages/signup.dart';
import 'package:bettersociety/pages/upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bettersociety/models/user.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final usersRef = FirebaseFirestore.instance.collection('users');
final storageRef = FirebaseStorage.instance.ref();
final followersRef = FirebaseFirestore.instance.collection('followers');
final DateTime timestamp = DateTime.now();
UserModel? currentUser;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
              const LoginPage(title: 'BetterSociety'),
          '/signup': (BuildContext context) => const SignupPage(),
          '/reset': (BuildContext context) => const ResetPasswordPage(),
          '/home': (BuildContext context) => const HomePage(),
          '/post': (BuildContext context) =>
              CreatePostPage(currentUser: currentUser!),
          '/upload': (BuildContext context) => const UploadPage(),
          '/achievements': (BuildContext context) => const AchievementsPage(),
          '/edit-profile': (BuildContext context) =>
              EditProfilePage(currentUserId: currentUser?.id),
          '/profile': (BuildContext context) => ProfilePage(
                profileId: currentUser?.id,
              ),
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
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {});
    }

    createUserInFirestore();
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
      });

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
