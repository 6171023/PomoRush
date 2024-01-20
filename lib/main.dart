import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'screens/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  _setUserToInactive() {
    users
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        await users
            .doc(value.docs.first.id)
            .update({"isActive": true})
            .then((value) {})
            .catchError((error) {});
      }
    });
  }

  @override
  void dispose() {
    _setUserToInactive();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GoogleAuthService().handleAuthState(),
    );
  }
}
