import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pomo_rush/models/user.dart';
import 'package:pomo_rush/screens/login.dart';
import 'package:pomo_rush/screens/timerSettingScreen.dart';
import 'package:pomo_rush/utils/preferences.dart';
import 'package:pomo_rush/animation/coin.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Stream<AuthUser> getUser() =>
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .snapshots()
          .map((snapshot) =>
      snapshot.docs.isNotEmpty
          ? AuthUser.fromJson(snapshot.docs.first.data())
          : AuthUser(
        createdAt: DateTime.now(),
        isActive: true,
        displayName: '',
        email: '',
        photoURL: '',
        myPoints: 0.0,
        myMoney: 0.0,
        myBadge: 'None'
      ));

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

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          const TimerSettingsScreen(
                            isChallenge: false,
                          ))).then((value) {
                    if (value != null && value) {}
                  });
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                      Size(MediaQuery
                          .of(context)
                          .size
                          .width * 0.75, 40)), // Increase height here
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Small curve on the sides
                    ),
                  ),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  backgroundColor:
                  MaterialStateProperty.all(Styles.pomodoroPrimaryColor),
                ),
                child: const Text(
                  'Use the Pomodoro Timer',
                  style: TextStyle(fontSize: 18), // Increase font size here
                ),
              ),
            ],
          )),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 30, right: 128, left: 128),
        // Add bottom padding
        child: Container(
          width: 100, // Specify width
          height: 50, // Specify height
          decoration: BoxDecoration(
            color: Styles.pomodoroPrimaryColor,
            borderRadius: BorderRadius.circular(30), // Rounded corners
          ),
          child: TextButton(
            onPressed: () {
              GoogleAuthService().signOut();
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
            child: const Text(
              'SIGN OUT',
              style: TextStyle(fontSize: 18), // Adjust font size here
            ),
          ),
        ),
      ),
    );
  }

  Widget getUserInfo(AuthUser user) =>
      Column(
        children: [

          Text(
            'Hi ${user.displayName}!',
            style: TextStyle(
              fontSize: 25,
              color: Styles.pomodoroPrimaryColor,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(45.0), // Add margins here
                child: Column(
                  children: [
                    PointFlip(points: user.myPoints),
                    Text(
                      'Points: ${user.myPoints}',
                      style: TextStyle(
                        fontSize: 20,
                        color: Styles.pomodoroPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.all(10.0), // Add margins here
                child: Column(
                  children: [
                    CoinFlip(money: user.myMoney),
                    Text(
                      'Money: ${user.myMoney}',
                      style: TextStyle(
                        fontSize: 20,
                        color: Styles.pomodoroPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
          'Currently equipped badge: ${user.myBadge}',
          style: TextStyle(
            fontSize: 20,
            color: Styles.pomodoroPrimaryColor,
          ),
          ),
        ],
      );
}