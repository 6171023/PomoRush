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
    _padding = 12.0;
    _buttonOpacity = 0.5;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _padding),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(fontSize: 15.0, color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'IMPORTANT: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: '\n'),
                          TextSpan(
                            text: 'Please keep in mind that your *name* will be displayed on the global leaderboard that is accessible to ALL other users and your *email* will be displayed to other users you challenge.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedOpacity(
                          duration: Duration(milliseconds: 300),
                          opacity: _buttonOpacity,
                          child: Container(
                            child: SignInButton(
                              buttonType: ButtonType.google,
                              buttonSize: ButtonSize.small,
                              onPressed: () {
                                GoogleAuthService().signIn();
                              },
                            ),
                          ),
                        ),
                        Container(
                          width: 150,
                          child: Divider(
                            color: Colors.black.withOpacity(0.3),
                            thickness: 1,
                          ),
                        ),
                        AnimatedOpacity(
                          duration: Duration(milliseconds: 300),
                          opacity: _buttonOpacity,
                          child: Container(
                            child: SignInButton(
                              buttonType: ButtonType.appleDark,
                              buttonSize: ButtonSize.small,
                              onPressed: () {
                                AppleAuthService().signIn();
                              },
                            ),
                          ),
                        ),
                      ],
                    )
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
      },
    );
  }

  signIn() async {
    final GoogleSignInAccount? user =
    await GoogleSignIn(scopes: <String>['email']).signIn();

    final GoogleSignInAuthentication auth = await user!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken, idToken: auth.idToken);

    await FirebaseAuth.instance
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

      QuerySnapshot value = await users.where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).get();
      if (value.docs.isEmpty) {
        await users.add(user.toJson()).then((value) {}).catchError((error) {});
      } else {
        await users.doc(value.docs.first.id).update({"isActive": true}).then((value) {}).catchError((error) {});
      }
    });
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
  }

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
      var parts = email != null ? email.split('@') : [];
      var username = parts.isNotEmpty ? parts[0] : 'user';

      var photoURL = FirebaseAuth.instance.currentUser!.photoURL;
      if (photoURL == null) {
        photoURL = 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png';
      }

      var loginUser = {
        "myPoints": 0.0,
        "myMoney": 0.0,
        "myBadge": "None",
        "BadgeList": [],
        "displayName": credential.givenName != null ? '${credential.givenName} ${credential.familyName}' : username,
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

class Deletion {
  accountDeletion(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete your account?'),
            Text(
              'If you click on the yes button, your information will automatically be deleted and you will be redirected to the login page.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            Text(
              'In case you accidentally delete your account, contact pomoduel@gmail.com with the same email address you logged in with.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                      Size(MediaQuery.of(context).size.width * 0.85, 40),
                    ),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                  ),
                  child: const Text('No :)'),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    QuerySnapshot snapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
                        .get();

                    Map<String, dynamic>? userData = snapshot.docs.first.data() as Map<String, dynamic>?;

                    if (userData != null) {
                      await FirebaseFirestore.instance
                          .collection('delete')
                          .doc(snapshot.docs.first.id)
                          .set(userData);

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(snapshot.docs.first.id)
                          .delete();

                      QuerySnapshot challengesSnapshot = await FirebaseFirestore.instance
                          .collection('challenge')
                          .where('acceptorEmail', isEqualTo: FirebaseAuth.instance.currentUser!.email)
                          .get();

                      QuerySnapshot challengesSnapshot2 = await FirebaseFirestore.instance
                          .collection('challenge')
                          .where('requesterEmail', isEqualTo: FirebaseAuth.instance.currentUser!.email)
                          .get();

                      List<DocumentSnapshot> allDocuments = [...challengesSnapshot.docs, ...challengesSnapshot2.docs];

                      for (DocumentSnapshot challengeDoc in allDocuments) {
                        await challengeDoc.reference.delete();
                      }
                    }

                    await FirebaseAuth.instance.signOut();

                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AppleAuthService().handleAuthState()));
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                      Size(MediaQuery.of(context).size.width * 0.85, 40),
                    ),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(Colors.red.shade900),
                  ),
                  child: const Text('Yes :('),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
