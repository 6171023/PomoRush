// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:pomo_rush/utils/preferences.dart';
import 'package:pomo_rush/widgets/personalTimerWidget.dart';

class TimerSettingsScreen extends StatefulWidget {
  const TimerSettingsScreen({super.key, required this.isChallenge});
  final bool isChallenge;
  @override
  State<TimerSettingsScreen> createState() => _TimerSettingsScreenState();
}

class _TimerSettingsScreenState extends State<TimerSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Styles.pomodoroPrimaryColor,
          title: widget.isChallenge
              ? const Text('Pomodoro Challenge')
              : const Text('Pomodoro Timer'),
        ),
        body: const SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: PersonalTimerWidget(),
            )));
  }
}