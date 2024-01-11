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
              children: challenge.map(buildChallenge).toList(),
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
            title: Text(challenge.acceptorDisplayName),
            subtitle: Text(challenge.acceptorEmail),
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
          ),
          child: const Text('Start'),
        )
            : challenge.status == "request" &&
            challenge.acceptorEmail ==
                FirebaseAuth.instance.currentUser!.email
            ? TextButton(
          onPressed: () {
            _acceptChallenge(challenge.id);
          },
          style: ButtonStyle(
            foregroundColor:
            MaterialStateProperty.all(Colors.white),
            backgroundColor:
            MaterialStateProperty.all(Colors.blue),
          ),
          child: const Text('Accept'),
        )
            : challenge.acceptorEmail ==
            FirebaseAuth.instance.currentUser!.email &&
            challenge.acceptorState == "Done"
            ? Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(20)),
          child: const Center(
              child: Text(
                'Done',
                style: TextStyle(color: Colors.white),
              )),
        )
            : challenge.requesterEmail ==
            FirebaseAuth.instance.currentUser!.email &&
            challenge.requesterState == "Done"
            ? Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(20)),
          child: const Center(
              child: Text(
                'Done',
                style: TextStyle(color: Colors.white),
              )),
        )
            : challenge.status == "started"
            ? TextButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChallengeTimerWidget(
                            challenge: challenge)));
          },
          style: ButtonStyle(
            foregroundColor:
            MaterialStateProperty.all(
                Colors.white),
            backgroundColor:
            MaterialStateProperty.all(
                Styles.pomodoroPrimaryColor),
          ),
          child: const Text('Open'),
        )
            : Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              color: Styles.pomodoroPrimaryColor,
              borderRadius:
              BorderRadius.circular(20)),
          child: Center(
              child: Text(
                challenge.status,
                style:
                const TextStyle(color: Colors.white),
              )),
        )
      ],
    ),
  );
}