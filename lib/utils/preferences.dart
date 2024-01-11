import 'package:flutter/material.dart';

class Styles {
  static Color pomodoroPrimaryColor = const Color(0xff440D0F);
}

class AppResponse {
// This code defines a static method called showAlertBottomSheet that displays a modal bottom sheet to show an alert.
  static Future showAlertBottomSheet(
      {required String title,
        required String message,
        required BuildContext context,
        required Color color}) async {
    // It uses the showModalBottomSheet widget to show the alert bottom sheet.
    return showModalBottomSheet<void>(
        enableDrag: false,
        backgroundColor: Theme.of(context).cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        ),
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // The bottom sheet is built inside a StatefulBuilder so that it can be closed once the user performs an action.
              return Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0)),
                  ),
                  child: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 120,
                                      child: Divider(
                                        color: Colors.white,
                                        thickness: 0.5,
                                      ),
                                    ),
                                    Text(message,
                                        textAlign: TextAlign.center,
                                        style:
                                        const TextStyle(color: Colors.white)),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ])))));
            }));
  }
}