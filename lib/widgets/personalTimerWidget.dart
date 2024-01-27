import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pomo_rush/utils/preferences.dart';
import 'package:pomo_rush/utils/utils.dart';

class PersonalTimerWidget extends StatefulWidget {
  const PersonalTimerWidget({super.key});

  @override
  State<PersonalTimerWidget> createState() => _PersonalTimerWidgetState();
}

class _PersonalTimerWidgetState extends State<PersonalTimerWidget> {
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
          // await _recordPointAfterCompleteOneSet(
          //     double.parse(focusMinutes.text));
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


  @override
  void initState() {
    isFocus = true;
    focusMinutes.text = "25";
    breaktime.text = "5";
    sets.text = "4";
    breakTimerTime = Duration(minutes: 25); // Update breakTimerTime to 25 minutes
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
                  isFocus ? const Text('Focus', style: TextStyle(color: Colors.greenAccent, fontSize: 25.0)) : const Text('Break', style: TextStyle(color: Colors.limeAccent, fontSize: 25.0)),
                  const SizedBox(height: 5),
                  isFocus
                      ? Text(
                    '${timerTime.inHours.toString().padLeft(2, "0")}:${timerTime.inMinutes.toString().padLeft(2, "0")}:${timerTime.inSeconds.remainder(60).toString().padLeft(2, "0")}',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 35.0),
                  )
                      : Text(
                    '${breakTimerTime.inHours.toString().padLeft(2, "0")}:${breakTimerTime.inMinutes.toString().padLeft(2, "0")}:${breakTimerTime.inSeconds.remainder(60).toString().padLeft(2, "0")}',
                    style: TextStyle(color: Colors.limeAccent, fontSize: 35.0),
                  ),
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
          const SizedBox(
            height: 10,
          ),
          const Text(
            'The strict mode option, if enabled, restricts you from pausing the timer once it starts.',
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