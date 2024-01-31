import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pomo_rush/models/user.dart';
import 'package:pomo_rush/screens/menu.dart';
import 'package:pomo_rush/utils/preferences.dart';
import 'package:pomo_rush/animation/confetti.dart';
import 'package:sign_button/sign_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:async';
import 'package:confetti/confetti.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Timer _timer;
  double _padding = 16.0;
  double _buttonOpacity = 1.0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _padding = _padding == 16.0 ? 8.0 : 16.0;
        _buttonOpacity = _buttonOpacity == 1.0 ? 0.5 : 1.0;
      });
    });
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _confettiController.play();
  }

  @override
  void dispose() {
    _timer.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Styles.pomodoroPrimaryColor,
            title: Text(
              "PomoRush",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _padding),
                  child: Text(
                    'Welcome to PomoRush!',
                    style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _padding),
                  child: Text(
                    'Nice to have you here :)',
                    style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedOpacity(
                      duration: Duration(milliseconds: 300),
                      opacity: _buttonOpacity,
                      child: SignInButton(
                        buttonType: ButtonType.google,
                        buttonSize: ButtonSize.large,
                        onPressed: () {
                          GoogleAuthService().signIn();
                        },
                      ),
                    ),
                    // SizedBox(width: 20), // Adjust this value to increase or decrease the space between the buttons
                    Container(
                      width: 200, // Set the desired width here
                      child: Divider(
                        color: Colors.black.withOpacity(0.3),
                        thickness: 1,
                      ),
                    ),
                    // SizedBox(width: 20), // Adjust this value to increase or decrease the space between the buttons
                    AnimatedOpacity(
                      duration: Duration(milliseconds: 300),
                      opacity: _buttonOpacity,
                      child: SignInButton(
                        buttonType: ButtonType.apple,
                        buttonSize: ButtonSize.large,
                        onPressed: () {
                          AppleAuthService().signIn();
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: ConfettiAnimation(_confettiController),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: ConfettiAnimation(_confettiController),
        ),
      ],
    );
  }
}


class GoogleAuthService {
  handleAuthState() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, currAuthState) {
          if (currAuthState.hasData) {
            return const Menu();
          } else {
            return const LoginPage();
          }
        });
  }

  signIn() async {
    final GoogleSignInAccount? user =
    await GoogleSignIn(scopes: <String>['email']).signIn();

    final GoogleSignInAuthentication auth = await user!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken, idToken: auth.idToken);

    return await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((value) async {
      var loginUser = {
        "myPoints": 0.0,
        "myMoney": 0.0,
        "myBadge": "None",
        "BadgeList": [],
        "displayName": FirebaseAuth.instance.currentUser!.displayName,
        "isActive": true,
        "email": FirebaseAuth.instance.currentUser!.email,
        "created_at": DateTime.now().toString(),
        "photoURL": FirebaseAuth.instance.currentUser!.photoURL
      };

      CollectionReference users =
      FirebaseFirestore.instance.collection('users');

      AuthUser user = AuthUser.fromJson(loginUser);

      users
          .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get()
          .then((value) async {
        if (value.docs.isEmpty) {
          await users
              .add(user.toJson())
              .then((value) {})
              .catchError((error) {});
        } else {
          await users
              .doc(value.docs.first.id)
              .update({"isActive": true})
              .then((value) {})
              .catchError((error) {});
        }
      });
    });
  }

  signOut() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        await users
            .doc(value.docs.first.id)
            .update({"isActive": false}).then((value) {
          FirebaseAuth.instance.signOut();
        }).catchError((error) {});
      }
    });
  }
// signOut() async {
//   await FirebaseAuth.instance.signOut();
// }

}

class AppleAuthService {
  handleAuthState() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, currAuthState) {
        if (currAuthState.hasData) {
          return const Menu();
        } else {
          return const LoginPage();
        }
      },
    );
  }

  signIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.fullName,
          AppleIDAuthorizationScopes.email,
        ],
      );

      final authCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      await FirebaseAuth.instance.signInWithCredential(authCredential);

      var email = FirebaseAuth.instance.currentUser!.email;
      var photoURL = FirebaseAuth.instance.currentUser!.photoURL;

      var parts = email != null ? email.split('@') : [];

      var displayName = parts.isNotEmpty ? parts[0] : 'user';

      if (photoURL == null) {
        photoURL = 'https://i.pinimg.com/736x/6b/ed/12/6bed123accf95b38fb97e32f39df4c2e.jpg';
      }

      var loginUser = {
        "myPoints": 0.0,
        "myMoney": 0.0,
        "myBadge": "None",
        "BadgeList": [],
        "displayName": displayName,
        "isActive": true,
        "email": FirebaseAuth.instance.currentUser!.email,
        "created_at": DateTime.now().toString(),
        "photoURL": photoURL
      };

      CollectionReference users = FirebaseFirestore.instance.collection('users');

      QuerySnapshot userQuery = await users.where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).get();

      if (userQuery.docs.isEmpty) {
        await users.add(loginUser);
      } else {
        await users.doc(userQuery.docs.first.id).update(loginUser);
      }
    } catch (error) {
      throw error;
    }
  }

  signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      throw error;
    }
  }

}