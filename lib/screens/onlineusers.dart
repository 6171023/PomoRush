import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pomo_rush/models/user.dart';
import 'package:pomo_rush/utils/preferences.dart';

class OnlineActiveUsers extends StatefulWidget {
  const OnlineActiveUsers({super.key});

  @override
  State<OnlineActiveUsers> createState() => _OnlineActiveUsersState();
}

class _OnlineActiveUsersState extends State<OnlineActiveUsers> {
  late String currentUserDisplayName = '';
  bool isloading = false;

  Stream<List<AuthUser>> readUsers() => FirebaseFirestore.instance
      .collection('users')
      .orderBy('displayName', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => AuthUser.fromJson(doc.data()))
      .toList());

  late DateTime createdAt;
  late String winner = '';
  late String acceptorEmail = '';
  late String acceptorName = '';
  late String acceptorEndTime = '';
  late String challengeEndTime = '';
  late String? requesterEmail = '';
  late String requesterName = '';
  late String requesterEndTime = '';
  late String challengeStartTime = '';
  late int breakTime = 5;
  late int focusTime = 25;
  late int setCount = 4;

  _requestChallenge() async {
    setState(() {
      isloading = true;
    });

    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: requesterEmail)
        .get();
    DocumentSnapshot userDoc = userSnapshot.docs.first;
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    requesterName = userData['displayName'];

    CollectionReference challenge = FirebaseFirestore.instance.collection('challenge');
    DateTime now = DateTime.now();
    var data = {
      "createdAt": now,
      "winner": winner,
      "acceptorDisplayName": acceptorName,
      "requesterDisplayName": requesterName,
      "acceptorEmail": acceptorEmail,
      "acceptorEndTime": acceptorEndTime,
      "breakTime": breakTime,
      "challengeEndTime": challengeEndTime,
      "challengeStartTime": challengeStartTime,
      "focusTime": focusTime,
      "requesterEmail": requesterEmail,
      "requesterEndTime": requesterEndTime,
      "setCount": setCount,
      "status": "request",
      "startedBy": "",
      "acceptorPoints": 0,
      "requesterPoint": 0,
      "acceptorCurrentTimer": "00:00:00",
      "requesterCurrentTimer": "00:00:00",
      "acceptorCurrentState": "Focus",
      "requesterCurrentState": 'Focus',
      "requesterState": "started",
      "acceptorState": "started"
    };

    await challenge.add(data).then((value) {
      setState(() {
        isloading = false;
      });

      AppResponse.showAlertBottomSheet(
          title: 'Request Sent',
          message: "Request sent successfully",
          context: context,
          color: Colors.green);
    }).catchError((error) {
      setState(() {
        isloading = false;
      });

      AppResponse.showAlertBottomSheet(
          title: 'Failed',
          message: "Something went wrong. Request failed",
          context: context,
          color: Colors.red);
    });
  }

  late TextEditingController focusMinutes = TextEditingController(text: "25");
  late TextEditingController breaktime = TextEditingController(text: "5");
  late TextEditingController sets = TextEditingController(text: "4");

  _showSetTimerDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Request to ${acceptorName.split(" ")[0]}'),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(
                          MediaQuery.of(context).size.width * 0.85, 40)),
                      foregroundColor:
                      MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(
                          Styles.pomodoroPrimaryColor),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                        isloading = true;
                      });
                      _requestChallenge();
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(
                          MediaQuery.of(context).size.width * 0.85, 40)),
                      foregroundColor:
                      MaterialStateProperty.all(Colors.white),
                      backgroundColor:
                      MaterialStateProperty.all(Colors.green),
                    ),
                    child: const Text('Send'),
                  ),
                )
              ],
            ),
          ],
          content: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Specify focus, break and repeat set on the fields.',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Focus minutes'),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: focusMinutes,
                    decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Enter minutes',
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Styles.pomodoroPrimaryColor)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Styles.pomodoroPrimaryColor))),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(
                          () {
                        if (value.isNotEmpty) {
                          setState(() {
                            focusTime = int.parse(value);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Break minutes'),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: breaktime,
                    decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Enter minutes',
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Styles.pomodoroPrimaryColor)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Styles.pomodoroPrimaryColor))),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(
                          () {
                        if (value.isNotEmpty) {
                          setState(() {
                            breakTime = int.parse(value);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Set count'),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: sets,
                    decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Enter number',
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Styles.pomodoroPrimaryColor)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Styles.pomodoroPrimaryColor))),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(
                          () {
                        if (value.isNotEmpty) {
                          setState(() {
                            setCount = int.parse(value);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ]),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return isloading
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<List<AuthUser>>(
      stream: readUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final users = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Use the request button to send challenges to anyone here and use the challenge screen to view your request status and/or participate in the accepted challenges.',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return buildUser(users[index]);
                  },
                ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget buildUser(AuthUser user) => Stack(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.photoURL),
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 5),
                    user.email == FirebaseAuth.instance.currentUser!.email
                        ? Container(
                      padding: const EdgeInsets.only(
                          left: 5.0,
                          right: 5.0,
                          top: 2.0,
                          bottom: 2.0),
                      decoration: BoxDecoration(
                          color: Styles.pomodoroPrimaryColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Center(
                          child:
                          Text(
                            'You',
                            style: TextStyle(
                                fontSize: 12.0, color: Colors.white),
                          )),
                    )
                        : Container()
                  ],
                ),
                subtitle:
                Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: [
                      user.myBadgeImagePath != null
                          ? Row(
                        children: [
                          Text(
                            'Badge: ',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          Image.asset(
                            user.myBadgeImagePath!,
                            width: 30,
                            height: 30,
                          ),
                        ],
                      )
                          : Text(
                        'Badge: ${user.myBadge}',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

              ),
            ),
            user.email == FirebaseAuth.instance.currentUser!.email
                ? Container()
                : ElevatedButton(
              onPressed: () {
                setState(() {
                  requesterEmail = FirebaseAuth.instance.currentUser!.email;
                  acceptorEmail = user.email;
                  acceptorName = user.displayName;
                });
                _showSetTimerDialog();
              },
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(
                    Size(MediaQuery.of(context).size.width / 4, 40)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(Styles.pomodoroPrimaryColor),
                elevation: MaterialStateProperty.all(5),
              ),
              child: const Text('Request'),
            )
          ],
        ),
      ),
      Positioned(
          top: 20,
          left: 50,
          child: user.isActive
              ? const CircleAvatar(
            backgroundColor: Colors.green,
            radius: 6,
          )
              : Container())
    ],
  );
}