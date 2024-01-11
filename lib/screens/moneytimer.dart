// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pomo_rush/utils/preferences.dart';
import 'package:pomo_rush/utils/utils.dart';

class MoneyTimerWidget extends StatefulWidget {
  const MoneyTimerWidget({super.key});

  @override
  State<MoneyTimerWidget> createState() => _MoneyTimerWidgetState();
}

class _MoneyTimerWidgetState extends State<MoneyTimerWidget> {
  late Timer _timer;
  late Timer _breakTimer;
  bool isFocus = false;

  bool disableFields = false;

  //input for focus minutes
  late TextEditingController focusMinutes = TextEditingController(text: "25");
  late TextEditingController breaktime = TextEditingController(text: "5");
  late TextEditingController sets = TextEditingController(text: "4");

  bool strictIsActive = false;
  bool paused = false;
  late Duration timerTime = Duration(
      minutes: focusMinutes.text.isEmpty ? 25 : int.parse(focusMinutes.text));
  late Duration breakTimerTime =
  Duration(minutes: breaktime.text.isEmpty ? 5 : int.parse(breaktime.text));

  _startFocusTimer() async {
    _stopTimer();
    if (int.parse(sets.text) > 0) {
      if (timerTime.inSeconds <= 0 && breakTimerTime.inSeconds <= 0) {
        setState(() {
          timerTime = Duration(
              minutes: focusMinutes.text.isEmpty
                  ? 25
                  : int.parse(focusMinutes.text));
        });
      }
      setState(() {
        disableFields = true;
        isFocus = true;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (timerTime.inSeconds <= 0) {
          timer.cancel();
          await _recordMoneyAfterCompleteOneSet(
              double.parse(focusMinutes.text));
          //decrease the set count
          if (sets.text.isNotEmpty) {
            //check if the set still active
            if (int.parse(sets.text) > 0) {
              _startBreakTimer();
            }
          }
        } else {
          setState(() {
            timerTime = Duration(seconds: timerTime.inSeconds - 1);
          });
        }
      });
    }
  }

  _startBreakTimer() {
    if (breakTimerTime.inSeconds <= 0) {
      setState(() {
        breakTimerTime = Duration(
            minutes: breaktime.text.isEmpty ? 5 : int.parse(breaktime.text));
      });
    }

    setState(() {
      disableFields = true;
      isFocus = false;
    });

    _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (breakTimerTime.inSeconds <= 0) {
        timer.cancel();
        if (sets.text.isNotEmpty) {
          //check if the set still active
          if (int.parse(sets.text) > 0) {
            setState(() {
              sets.text = (int.parse(sets.text) - 1).toString();
            });
            _startFocusTimer();
          } else {
            setState(() {
              disableFields = false;
              isFocus = false;
            });
          }
        }
      } else {
        setState(() {
          breakTimerTime = Duration(seconds: breakTimerTime.inSeconds - 1);
        });
      }
    });
  }

  _resetTimer() {
    _stopTimer();
    setState(() {
      timerTime = const Duration(minutes: 25);
      breakTimerTime = const Duration(minutes: 5);
      focusMinutes = TextEditingController(text: "25");
      breaktime = TextEditingController(text: "5");
      sets = TextEditingController(text: "4");
      disableFields = false;
      isFocus = true;
    });
  }

  _stopTimer() {
    try {
      _timer.cancel();
      _breakTimer.cancel();
    } catch (_) {}
  }

  _storeLastTimerCount() async {
    bool timeIsActive = false;
    bool breakTimerIsActive = false;

    try {
      timeIsActive = _timer.isActive;
    } catch (_) {}

    try {
      breakTimerIsActive = _breakTimer.isActive;
    } catch (_) {}

    try {
      //check is all timer have been initialized
      var timers = {
        "focus": isFocus,
        "focusTimer": timerTime.toString(),
        "breakTimer": breakTimerTime.toString(),
        "sets": sets.text,
        "strictMode": strictIsActive,
        "timerIsActive": timeIsActive,
        "breakTimerIsActive": breakTimerIsActive
      };
      await AppStorage.storeDataInSecureStorage(
          key: 'timers', data: jsonEncode(timers));
    } catch (_) {}
  }

  _readLastTimerCount() async {
    await AppStorage.readDataFromSecureStorage(key: 'timers')
        .then((timerCount) {
      var lastTimer = jsonDecode(timerCount!);

      if (lastTimer != null) {
        timerTime = Duration(
            hours: int.parse(lastTimer["focusTimer"].toString().split(":")[0]),
            minutes:
            int.parse(lastTimer["focusTimer"].toString().split(":")[1]),
            seconds: int.parse(lastTimer["focusTimer"]
                .toString()
                .split(":")[2]
                .split(".")[0]));
        breakTimerTime = Duration(
            hours: int.parse(lastTimer["breakTimer"].toString().split(":")[0]),
            minutes:
            int.parse(lastTimer["breakTimer"].toString().split(":")[1]),
            seconds: int.parse(lastTimer["breakTimer"]
                .toString()
                .split(":")[2]
                .split(".")[0]));
        focusMinutes = TextEditingController(
            text: lastTimer["focusTimer"].toString().split(":")[1]);
        breaktime = TextEditingController(
            text: lastTimer["breakTimer"].toString().split(":")[1]);
        sets = TextEditingController(text: lastTimer["sets"].toString());
        strictIsActive = lastTimer["strictMode"];
        isFocus = lastTimer["focus"];

        if (lastTimer["timerIsActive"]) {
          _startFocusTimer();
        } else if (lastTimer["breakTimerIsActive"]) {
          _startBreakTimer();
        } else {
          setState(() {});
        }
      }
    });
  }

  _recordMoneyAfterCompleteOneSet(double money) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        double currentMoney =
        double.parse(value.docs.first["myMoney"].toString());
        double updatedMoney = currentMoney + (money / 2); // Divide focus minutes by 2
        await users
            .doc(value.docs.first.id)
            .update({"myMoney": updatedMoney})
            .then((value) {})
            .catchError((error) {});
      }
    });
  }

  @override
  void initState() {
    _readLastTimerCount();
    super.initState();
  }

  @override
  void dispose() {
    _storeLastTimerCount();
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          const Text(
            'Specify your focus, break and repeat set on the fields.',
            textAlign: TextAlign.start,
          ),
          const Text(
            'Earn money based on how long you focus for. (Money=Total focus time/2)',
            textAlign: TextAlign.start,
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Focus minutes'),
                    TextField(
                      controller: focusMinutes,
                      readOnly: disableFields,
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
                              timerTime = Duration(minutes: int.parse(value));
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 3,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Break minutes'),
                    TextField(
                      controller: breaktime,
                      readOnly: disableFields,
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
                              breakTimerTime =
                                  Duration(minutes: int.parse(value));
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 3,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Set count'),
                    TextField(
                      controller: sets,
                      readOnly: disableFields,
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
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: disableFields
                      ? null
                      : () {
                    _startFocusTimer();
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(disableFields
                        ? Colors.grey
                        : Styles.pomodoroPrimaryColor),
                  ),
                  child: const Text('Start'),
                ),
              ),
              const SizedBox(
                width: 3,
              ),
              Expanded(
                child: paused
                    ? TextButton(
                  onPressed: strictIsActive || !isFocus
                      ? null
                      : () {
                    setState(() {
                      paused = false;
                    });

                    if (isFocus) {
                      _startFocusTimer();
                    }
                  },
                  style: ButtonStyle(
                    foregroundColor:
                    MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(
                        strictIsActive || !isFocus
                            ? Colors.grey
                            : Styles.pomodoroPrimaryColor),
                  ),
                  child: const Text('Resume'),
                )
                    : TextButton(
                  onPressed: strictIsActive || !disableFields
                      ? null
                      : () {
                    setState(() {
                      paused = true;
                    });
                    _stopTimer();
                  },
                  style: ButtonStyle(
                    foregroundColor:
                    MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(
                        strictIsActive || !disableFields
                            ? Colors.grey
                            : Styles.pomodoroPrimaryColor),
                  ),
                  child: const Text('Pause'),
                ),
              ),
              const SizedBox(
                width: 3,
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _resetTimer();
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor:
                    MaterialStateProperty.all(Styles.pomodoroPrimaryColor),
                  ),
                  child: const Text('Reset'),
                ),
              )
            ],
          ),
          ListTile(
            title: Row(
              children: [
                const Text('Strict Mode'),
                Switch(
                    focusColor: Styles.pomodoroPrimaryColor,
                    activeColor: Styles.pomodoroPrimaryColor,
                    value: strictIsActive,
                    onChanged: (value) {
                      setState(() {
                        if (!disableFields) {
                          strictIsActive = value;
                        }
                      });
                    }),
              ],
            ),
          )
        ]);
  }
}