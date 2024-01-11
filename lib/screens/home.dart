import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pomo_rush/models/user.dart';
import 'package:pomo_rush/screens/login.dart';
import 'package:pomo_rush/screens/timerSettingScreen.dart';
import 'package:pomo_rush/utils/preferences.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Stream<AuthUser> getUser() => FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
      .snapshots()
      .map((snapshot) => snapshot.docs.isNotEmpty
      ? AuthUser.fromJson(snapshot.docs.first.data())
      : AuthUser(
      createdAt: DateTime.now(),
      isActive: true,
      displayName: '',
      email: '',
      photoURL: '',
      myPoints: 0.0,
      myMoney: 0.0,
      badge: 'None'));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StreamBuilder<AuthUser>(
                  stream: getUser(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final users = snapshot.data!;

                      return getUserInfo(users);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TimerSettingsScreen(
                            isChallenge: false,
                          ))).then((value) {
                    if (value != null && value) {}
                  });
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                      Size(MediaQuery.of(context).size.width * 0.85, 40)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  backgroundColor:
                  MaterialStateProperty.all(Styles.pomodoroPrimaryColor),
                ),
                child: const Text('Set Focus time'),
              ),
            ],
          )),
      bottomNavigationBar: TextButton(
        onPressed: () {
          GoogleAuthService().signOut();
        },
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
              const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          backgroundColor:
          MaterialStateProperty.all(Styles.pomodoroPrimaryColor),
        ),
        child: const Text('Sign Out'),
      ),
    );
  }

  Widget getUserInfo(AuthUser user) => Column(
    children: [
      Text(
        'Hi ${user.displayName}!',
        style: TextStyle(
          fontSize: 25,
          color: Styles.pomodoroPrimaryColor,
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Accumulated Points: ${user.myPoints}',
        style: TextStyle(
          fontSize: 20,
          color: Styles.pomodoroPrimaryColor,
        ),
      ),
      Text(
        'Accumulated Money: ${user.myMoney}',
        style: TextStyle(
        fontSize: 20,
        color: Styles.pomodoroPrimaryColor,
        ),
      ),
      Text(
        'Currently equipped badge: ${user.badge}',
        style: TextStyle(
          fontSize: 20,
          color: Styles.pomodoroPrimaryColor,
        ),
      ),
    ],
  );
}