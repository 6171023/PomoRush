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
              ? Text('Pomodoro Challenge Timer', style: TextStyle(color: Colors.white))
              : Text('Pomodoro Timer', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white), // Custom back button
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: PersonalTimerWidget(),
            )));
  }
}