import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pomo_rush/models/user.dart';
import 'package:pomo_rush/utils/preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.pomodoroPrimaryColor,
        title: Text("POMORUSH",
          style: TextStyle(color: Colors.white,
        ),
        ),
      ),
      body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                "Please sign in :)",
                style: TextStyle(fontSize: 30, color: Colors.black),
              ),
              SignInButton(
                buttonType: ButtonType.google,
                buttonSize: ButtonSize.small,
                onPressed: () {
                  GoogleAuthService().signIn();
                },
              ),
            ],
          )),
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
