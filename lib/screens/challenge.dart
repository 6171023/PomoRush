import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pomo_rush/models/challenge.dart';
import 'package:pomo_rush/utils/preferences.dart';
import 'package:pomo_rush/widgets/challengeTimerWidget.dart';

class ChallengeListScreen extends StatefulWidget {
  const ChallengeListScreen({Key? key});

  @override
  State<ChallengeListScreen> createState() => _ChallengeListScreenState();
}

class _ChallengeListScreenState extends State<ChallengeListScreen> {
  bool isLoading = false;

  Stream<List<Challenge>> readChallenges() => FirebaseFirestore.instance
      .collection('challenge')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
      .where((doc) => doc['acceptorEmail'] == FirebaseAuth.instance.currentUser!.email || doc['requesterEmail'] == FirebaseAuth.instance.currentUser!.email)
      .map((doc) => Challenge.fromJson(doc.data() as Map<String, dynamic>, doc.id))
      .toList())
      .handleError((onError) {});

  Future<bool> checkUserExists(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  _startChallenge(String docId, Challenge chlg) async {
    setState(() {
      isLoading = true;
    });

    CollectionReference challenge = FirebaseFirestore.instance.collection('challenge');

    try {
      await challenge.doc(docId).update({
        "status": "started",
        "startedBy": FirebaseAuth.instance.currentUser!.email,
      });

      // Determine the winner if one of the users has completed the challenge
      if (chlg.acceptorEmail == FirebaseAuth.instance.currentUser!.email &&
          chlg.acceptorState == "Done" &&
          chlg.requesterState != "Done") {
        // If the acceptor finished the challenge first, they are the winner
        await challenge.doc(docId).update({
          "winner": FirebaseAuth.instance.currentUser!.email,
        });
      } else if (chlg.requesterEmail == FirebaseAuth.instance.currentUser!.email &&
          chlg.requesterState == "Done" &&
          chlg.acceptorState != "Done") {
        // If the requester finished the challenge first, they are the winner
        await challenge.doc(docId).update({
          "winner": FirebaseAuth.instance.currentUser!.email,
        });
      }

      setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChallengeTimerWidget(challenge: chlg),
        ),
      );

      // // Listen for challenge updates
      // _listenForChallengeUpdates(docId);

    } catch (error) {
      setState(() {
        isLoading = false;
      });
      AppResponse.showAlertBottomSheet(
        title: 'Failed',
        message: "Something went wrong. Request failed",
        context: context,
        color: Colors.red,
      );
    }
  }

  _acceptChallenge(String docId) async {
    setState(() {
      isLoading = true;
    });
    CollectionReference challenge = FirebaseFirestore.instance.collection('challenge');

    try {
      await challenge.doc(docId).update({"status": "accepted"});

      setState(() {
        isLoading = false;
      });

      AppResponse.showAlertBottomSheet(
        title: 'Request Accepted',
        message: "Challenge accepted successfully",
        context: context,
        color: Colors.green,
      );
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      AppResponse.showAlertBottomSheet(
        title: 'Failed',
        message: "Something went wrong. Request accept failed",
        context: context,
        color: Colors.red,
      );
    }
  }

  Widget buildChallenge(Challenge challenge) {
    return FutureBuilder<bool>(
      future: checkUserExists(
        challenge.acceptorEmail == FirebaseAuth.instance.currentUser!.email ||
            challenge.requesterEmail == FirebaseAuth.instance.currentUser!.email
            ? challenge.requesterEmail
            : challenge.acceptorEmail,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(
                          // Display the other person's display name
                          challenge.acceptorEmail == FirebaseAuth.instance.currentUser!.email
                              ? challenge.requesterDisplayName
                              : challenge.acceptorDisplayName,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          // Display the other person's email address
                          challenge.acceptorEmail == FirebaseAuth.instance.currentUser!.email
                              ? challenge.requesterEmail
                              : challenge.acceptorEmail,
                        ),
                      ),
                    ),
                    if (challenge.status == "accepted")
                      TextButton(
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
                        child: Center(
                          child: Text(
                            ' Start  \n ${challenge.focusTime}-${challenge.breakTime}-${challenge.setCount} ',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else if (challenge.status == "request" &&
                        challenge.acceptorEmail == FirebaseAuth.instance.currentUser!.email)
                      ElevatedButton(
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
                        child: Center(
                          child: Text(
                            ' Accept  \n ${challenge.focusTime}-${challenge.breakTime}-${challenge.setCount} ',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else if ((challenge.acceptorEmail == FirebaseAuth.instance.currentUser!.email &&
                          challenge.acceptorState == "Done" &&
                          challenge.winner == FirebaseAuth.instance.currentUser!.email) ||
                          (challenge.requesterEmail == FirebaseAuth.instance.currentUser!.email &&
                              challenge.requesterState == "Done" &&
                              challenge.winner == FirebaseAuth.instance.currentUser!.email))
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              ' WIN \n ${challenge.focusTime}-${challenge.breakTime}-${challenge.setCount} ',
                              style: TextStyle(
                                color: Colors.greenAccent,
                              ),
                            ),
                          ),
                        )
                      else if ((challenge.acceptorState == "Done" || challenge.requesterState == "Done") &&
                            !(challenge.acceptorState == "Done" && challenge.requesterState == "Done"))
                        // Display "Open" if either acceptor or requester has completed the challenge but not both
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChallengeTimerWidget(challenge: challenge),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                ' Open \n ${challenge.focusTime}-${challenge.breakTime}-${challenge.setCount} ',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                          else if (challenge.status=="started" && challenge.winner!=FirebaseAuth.instance.currentUser!.email)
                          // Display LOSS as the user has finished the challenge but hasn't won
                            Container(
                              padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  ' LOSS \n ${challenge.focusTime}-${challenge.breakTime}-${challenge.setCount}  ',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            )
                        else
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                challenge.status == "request"
                                    ? "Requested  \n ${challenge.focusTime}-${challenge.breakTime}-${challenge.setCount} "
                                    : challenge.status,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<List<Challenge>>(
      stream: readChallenges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<Challenge> challenges = snapshot.data!;
          final List<Challenge> doneChallenges = challenges.where((challenge) =>
          (challenge.acceptorEmail == FirebaseAuth.instance.currentUser!.email &&
              challenge.acceptorState == "Done") ||
              (challenge.requesterEmail == FirebaseAuth.instance.currentUser!.email &&
                  challenge.requesterState == "Done")).toList();
          final List<Challenge> requestChallenges = challenges.where((challenge) =>
          (challenge.acceptorEmail == FirebaseAuth.instance.currentUser!.email ||
              challenge.requesterEmail == FirebaseAuth.instance.currentUser!.email) &&
              challenge.status == "request").toList();
          return ListView(
            children: <Widget>[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Let's compete to earn points and finish challenges asap to see if you're the winner!",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'If you finish the challenge first, you will win. If your opponent finishes the challenge first, you will lose.',
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Neither you or your opponent will know if any of you finished the challenge first. So finish challenges as soon as you can if you want to win ;)',
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              const SizedBox(height: 10),
              ...challenges
                  .where((challenge) =>
              !doneChallenges.contains(challenge) && !requestChallenges.contains(challenge))
                  .map(buildChallenge)
                  .toList(),
              if (requestChallenges.isNotEmpty)
                Column(
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "REQUESTED CHALLENGES",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xff440D0F), width: 2),
                          ),
                          child: ListView(
                            children: requestChallenges.map((challenge) {
                              return buildChallenge(challenge);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (doneChallenges.isNotEmpty)
                Column(
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "COMPLETED CHALLENGES",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xff440D0F), width: 2),
                          ),
                          child: ListView(
                            children: doneChallenges.map((challenge) {
                              return buildChallenge(challenge);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

}
