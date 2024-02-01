import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pomo_rush/models/challenge.dart';
import 'package:pomo_rush/utils/preferences.dart';
import 'package:pomo_rush/widgets/challengeTimerWidget.dart';

class ChallengeListScreen extends StatefulWidget {
  const ChallengeListScreen({super.key});

  @override
  State<ChallengeListScreen> createState() => _ChallengeListScreenState();
}

class _ChallengeListScreenState extends State<ChallengeListScreen> {
  bool isloading = false;

  Stream<List<Challenge>> readChallenges() => FirebaseFirestore.instance
      .collection('challenge')
      .snapshots()
      .map((snapshot) => snapshot.docs
      .where((doc) => doc['acceptorEmail'] == FirebaseAuth.instance.currentUser!.email || doc['requesterEmail'] == FirebaseAuth.instance.currentUser!.email)
      .map((doc) => Challenge.fromJson(doc.data(), doc.id))
      .toList())
      .handleError((onError) {});


  late String acceptorEmail = '';
  late String acceptorName = '';
  late String acceptorEndTime = '';
  late String challengeEndTime = '';
  late String? requesterEmail = '';
  late String requesterEndTime = '';
  late String challengeStartTime = '';
  late int breakTime = 5;
  late int focusTime = 25;
  late int setCount = 4;

  _startChallenge(String docId, Challenge chlg) async {
    setState(() {
      isloading = true;
    });
    CollectionReference challenge =
    FirebaseFirestore.instance.collection('challenge');

    challenge.doc(docId).update({
      "status": "started",
      "startedBy": FirebaseAuth.instance.currentUser!.email
    }).then((value) {
      setState(() {
        isloading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChallengeTimerWidget(challenge: chlg)));
    }).catchError((onError) {
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

  _acceptChallenge(String docId) async {
    setState(() {
      isloading = true;
    });
    CollectionReference challenge =
    FirebaseFirestore.instance.collection('challenge');

    challenge.doc(docId).update({"status": "accepted"}).then((value) {
      setState(() {
        isloading = false;
      });
      AppResponse.showAlertBottomSheet(
          title: 'Request Sent',
          message: "Request sent successful",
          context: context,
          color: Colors.green);
    }).catchError((onError) {
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

  @override
  Widget build(BuildContext context) {
    return isloading
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<List<Challenge>>(
        stream: readChallenges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final challenge = snapshot.data!;

            return ListView(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'People you send and receive challenges from appear here.',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Let's compete in challenges to earn points and win!",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
                ...challenge.map(buildChallenge).toList(),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget buildChallenge(Challenge challenge) => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        Expanded(
          child: ListTile(
            title: Text(
              // Display the other person's display name
              challenge.acceptorEmail == FirebaseAuth.instance.currentUser!.email
                  ? challenge.requesterDisplayName
                  : challenge.acceptorDisplayName,
            ),
            subtitle: Text(
              // Display the other person's email address
              challenge.acceptorEmail == FirebaseAuth.instance.currentUser!.email
                  ? challenge.requesterEmail
                  : challenge.acceptorEmail,
            ),
          ),
        ),
        challenge.status == "accepted"
            ? TextButton(
          onPressed: () {
            _startChallenge(challenge.id, challenge);
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.white),
            backgroundColor: MaterialStateProperty.all(Colors.green),
            elevation: MaterialStateProperty.all(5),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          child: const Text('Start'),
        )
            : challenge.status == "request" &&
            challenge.acceptorEmail == FirebaseAuth.instance.currentUser!.email
            ? ElevatedButton(
          onPressed: () {
            _acceptChallenge(challenge.id);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: const Text('Accept'),
        )
            : challenge.acceptorEmail == FirebaseAuth.instance.currentUser!.email &&
            challenge.acceptorState == "Done"
            ? Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(20)),
          child: const Center(
              child: Text(
                ' Finished ',
                style: TextStyle(color: Colors.black),
              )),
        )
            : challenge.requesterEmail == FirebaseAuth.instance.currentUser!.email &&
            challenge.requesterState == "Done"
            ? Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(20)),
          child: const Center(
              child: Text(
                ' Finished ', //when both parties finish the challenge
                style: TextStyle(color: Colors.black),
              )),
        )
            : challenge.status == "started"
            ? OutlinedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChallengeTimerWidget(
                            challenge: challenge)));
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Styles.pomodoroPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: const Text('Open'),
        )
            : Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius:
              BorderRadius.circular(20)),
          child: Center(
              child: Text(
                challenge.status == "request" ? " Requested " : challenge.status,
                style: const TextStyle(color: Colors.white),
              )),
        )
      ],
    ),
  );
}