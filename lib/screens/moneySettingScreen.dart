import 'package:flutter/material.dart';
import 'package:pomo_rush/utils/preferences.dart';
import 'package:pomo_rush/widgets/moneytimer.dart';

class MoneySettingsScreen extends StatefulWidget {
  const MoneySettingsScreen({super.key});
  @override
  State<MoneySettingsScreen> createState() => _MoneySettingsScreenState();
}

class _MoneySettingsScreenState extends State<MoneySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.pomodoroPrimaryColor,
        title: Text('Pomodoro Money Timer', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Custom back button
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: MoneyTimerWidget(),
        ),
      ),
    );
  }
}
