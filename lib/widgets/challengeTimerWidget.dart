import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pomo_rush/models/challenge.dart';
import 'package:pomo_rush/utils/preferences.dart';

class ChallengeTimerWidget extends StatefulWidget {
  ChallengeTimerWidget({super.key, required this.challenge});
  Challenge challenge;
  @override
  State<ChallengeTimerWidget> createState() => _ChallengeTimerWidgetState();
}

class _ChallengeTimerWidgetState extends State<ChallengeTimerWidget> {
  late Timer _timer;
  late Timer _breakTimer;
  late Timer _uploadTimer;
  double currentPoints = 0;
  bool isFocus = true;

  bool strictIsActive = false;

  bool disableFields = false;
  bool paused = false;
  late Duration timerTime = Duration(minutes: widget.challenge.focusTime);
  late Duration breakTimerTime = Duration(minutes: widget.challenge.breakTime);

  Stream<Challenge> getChallenge() => FirebaseFirestore.instance
      .collection('challenge')
      .doc(widget.challenge.id)
      .snapshots()
      .map((snapshot) => Challenge.fromJson(snapshot.data()!, snapshot.id));

  _startFocusTimer() async {
    _stopTimer();
    if (widget.challenge.setCount > 0) {
      if (timerTime.inSeconds <= 0 && breakTimerTime.inSeconds <= 0) {
        setState(() {
          timerTime = Duration(minutes: widget.challenge.focusTime);
        });
      }
      setState(() {
        disableFields = true;
        isFocus = true;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (timerTime.inSeconds <= 0) {
          timer.cancel();
          await _recordPointAfterCompleteOneSet(widget.challenge.focusTime);

          //check if the set still active
          if (widget.challenge.setCount > 0) {
            _startBreakTimer();
          }
        } else {
          setState(() {
            timerTime = Duration(seconds: timerTime.inSeconds - 1);
          });
        }
      });
    } else {
      CollectionReference chlng =
      FirebaseFirestore.instance.collection('challenge');
      await chlng.doc(widget.challenge.id).update({
        FirebaseAuth.instance.currentUser!.email ==
            widget.challenge.acceptorEmail
            ? 'acceptorState'
            : 'requesterState': 'Done',
      }).then((value) {
        AppResponse.showAlertBottomSheet(
            title: 'Challenge Completed',
            message: "Congratulations! You have passed the challenge.",
            context: context,
            color: Colors.green);
      }).catchError((onError) {});
    }
  }

  _startBreakTimer() {
    if (breakTimerTime.inSeconds <= 0) {
      setState(() {
        disableFields = true;
        breakTimerTime = Duration(minutes: widget.challenge.breakTime);
      });
    }

    setState(() {
      isFocus = false;
    });

    _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (breakTimerTime.inSeconds <= 0) {
        timer.cancel();

        //check if the set still active
        if (widget.challenge.setCount > 0) {
          setState(() {
            widget.challenge.setCount = widget.challenge.setCount - 1;
          });
          _startFocusTimer();
        } else {
          setState(() {
            isFocus = false;
          });
        }
      } else {
        setState(() {
          breakTimerTime = Duration(seconds: breakTimerTime.inSeconds - 1);
        });
      }
    });
  }

  _stopTimer() {
    try {
      _timer.cancel();
      _breakTimer.cancel();
    } catch (_) {}
  }

  _recordPointAfterCompleteOneSet(int points) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        currentPoints =
            double.parse(value.docs.first["myPoints"].toString()) + points;
        await users
            .doc(value.docs.first.id)
            .update({"myPoints": currentPoints})
            .then((value) {})
            .catchError((error) {});
      }
    });
  }

  _showSetTimerDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Instructions'),
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
                      Navigator.pop(context);
                      _startFocusTimer();
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(
                          MediaQuery.of(context).size.width * 0.85, 40)),
                      foregroundColor:
                      MaterialStateProperty.all(Colors.white),
                      backgroundColor:
                      MaterialStateProperty.all(Colors.green),
                    ),
                    child: const Text('Start'),
                  ),
                )
              ],
            ),
          ],
          content: const SingleChildScrollView(
            child: Text(
              'Keep this screen open. After starting the timer, you will not be able to stop it. If this page will be closed, you will be required to start from the beginning for the challenge. Your opponent will be watching your timer in real time. Points will be recorded after completion of the challenge. Good luck!',
            ),
          ),
        ));
  }

  _saveCurrentTimer() async {
    CollectionReference chlng =
    FirebaseFirestore.instance.collection('challenge');
    await chlng
        .doc(widget.challenge.id)
        .update({
      FirebaseAuth.instance.currentUser!.email ==
          widget.challenge.acceptorEmail
          ? 'acceptorCurrentTimer'
          : 'requesterCurrentTimer':
      isFocus
          ? '${timerTime.inHours.toString().padLeft(2, "0")}:${timerTime.inMinutes.toString().padLeft(2, "0")}:${timerTime.inSeconds.remainder(60).toString().padLeft(2, "0")}'
          : '${breakTimerTime.inHours.toString().padLeft(2, "0")}:${breakTimerTime.inMinutes.toString().padLeft(2, "0")}:${breakTimerTime.inSeconds.remainder(60).toString().padLeft(2, "0")}',
      FirebaseAuth.instance.currentUser!.email ==
          widget.challenge.acceptorEmail
          ? 'acceptorPoints'
          : 'requesterPoint': currentPoints,
      FirebaseAuth.instance.currentUser!.email ==
          widget.challenge.acceptorEmail
          ? 'acceptorCurrentState'
          : 'requesterCurrentState': isFocus ? 'Focus' : 'Break'
    })
        .then((value) {})
        .catchError((onError) {});
  }

  @override
  void initState() {
    _uploadTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _saveCurrentTimer();
    });
    super.initState();
  }

  @override
  void dispose() {
    _uploadTimer.cancel();
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Styles.pomodoroPrimaryColor,
          title: const Text('Pomodoro Challenge')),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                FirebaseAuth.instance.currentUser!.email ==
                    widget.challenge.acceptorEmail
                    ? Text(
                  widget.challenge.acceptorDisplayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                )
                    : Text(
                  widget.challenge.requesterDisplayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: CircleAvatar(
                    backgroundColor: Styles.pomodoroPrimaryColor,
                    radius: MediaQuery.of(context).size.width / 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isFocus ? const Text('Focus') : const Text('Break'),
                        const SizedBox(height: 5),
                        isFocus
                            ? Text(
                            '${timerTime.inHours.toString().padLeft(2, "0")}:${timerTime.inMinutes.toString().padLeft(2, "0")}:${timerTime.inSeconds.remainder(60).toString().padLeft(2, "0")}')
                            : Text(
                            '${breakTimerTime.inHours.toString().padLeft(2, "0")}:${breakTimerTime.inMinutes.toString().padLeft(2, "0")}:${breakTimerTime.inSeconds.remainder(60).toString().padLeft(2, "0")}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Sets Remained: ${widget.challenge.setCount.toString()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                  onPressed: disableFields
                      ? null
                      : () {
                    _showSetTimerDialog();
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                        Size(MediaQuery.of(context).size.width, 40)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(
                        disableFields ? Colors.grey : Styles.pomodoroPrimaryColor),
                  ),
                  child: const Text('Start'),
                ),
                Divider(
                  color: Styles.pomodoroPrimaryColor,
                ),
                const Text(
                  "VS",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.green),
                ),
                Divider(
                  color: Styles.pomodoroPrimaryColor,
                ),
                FirebaseAuth.instance.currentUser!.email !=
                    widget.challenge.acceptorEmail
                    ? Text(
                  widget.challenge.acceptorDisplayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                )
                    : Text(
                  widget.challenge.requesterDisplayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(
                  height: 10,
                ),
                StreamBuilder<Challenge>(
                    stream: getChallenge(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final challenge = snapshot.data!;
                        return trackOpponentTimer(challenge);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    })
              ],
            ),
          )),
    );
  }

  Widget trackOpponentTimer(Challenge chal) => Center(
    child: CircleAvatar(
      backgroundColor: Styles.pomodoroPrimaryColor,
      radius: MediaQuery.of(context).size.width / 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FirebaseAuth.instance.currentUser!.email == chal.acceptorEmail
              ? Text(chal.requesterCurrentState)
              : Text(chal.acceptorCurrentState),
          const SizedBox(height: 5),
          FirebaseAuth.instance.currentUser!.email == chal.acceptorEmail
              ? Text(chal.requesterCurrentTimer)
              : Text(chal.acceptorCurrentTimer)
        ],
      ),
    ),
  );
}