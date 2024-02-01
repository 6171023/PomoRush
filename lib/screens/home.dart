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
        myBadge: 'None',
        purchasedBadges: [],
        myBadgeImagePath: null,
      ));

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StreamBuilder<AuthUser>(
              stream: getUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final user = snapshot.data!;
                  return getUserInfo(user);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TimerSettingsScreen(
                      isChallenge: false,
                    ),
                  ),
                ).then((value) {
                  if (value != null && value) {}
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width * 0.75, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                backgroundColor: Styles.pomodoroPrimaryColor,
                foregroundColor: Colors.white,
                elevation: 7
              ),
              child: Text(
                'Use the Pomodoro Timer',
                style: TextStyle(fontSize: 18),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                GoogleAuthService().signOut();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width * 0.3, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.black, width: 2),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Styles.pomodoroPrimaryColor,
                elevation: 10,
              ),
              child: Text(
                'SIGN OUT',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getUserInfo(AuthUser user) {
    return Column(
      children: [
        Text(
          'Hi ${user.displayName}!',
          style: TextStyle(
            fontSize: 25,
            color: Styles.pomodoroPrimaryColor,
          ),
        ),
        SizedBox(height: 30),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
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
              SizedBox(width: 30),
              Column(
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
            ],
          ),
        ),
        SizedBox(height: 50),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              user.myBadgeImagePath != null
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Equipped badge: ',
                    style: TextStyle(
                      fontSize: 20,
                      color: Styles.pomodoroPrimaryColor,
                    ),
                  ),
                  Image.asset(
                    user.myBadgeImagePath!,
                    width: 50,
                    height: 50,
                  ),
                ],
              )
                  : Text(
                'Equipped badge: ${user.myBadge}',
                style: TextStyle(
                  fontSize: 20,
                  color: Styles.pomodoroPrimaryColor,
                ),
              ),
            ],


          ),
        ),
      ],
    );
  }

}