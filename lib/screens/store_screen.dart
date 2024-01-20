import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomo_rush/screens/moneySettingScreen.dart';
import '../models/store.dart';
import 'package:pomo_rush/utils/preferences.dart';

class StoreScreen extends StatefulWidget {
  final Store store;

  const StoreScreen({Key? key, required this.store}) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late final List<StoreBadge> badges;
  String? equippedBadge;

  @override
  void initState() {
    super.initState();
    badges = widget.store.getAvailableBadges();
    fetchEquippedBadge();
  }

  Future<void> fetchEquippedBadge() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(
        FirebaseAuth.instance.currentUser!.uid).get();
    if (mounted) {
      setState(() {
        equippedBadge = snapshot.data()?['myBadge'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<double>(
                stream: widget.store.fetchUserMoney(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text(
                      'Available amount of money: \¥${snapshot.data}',
                      style: TextStyle(fontSize: 18.0),
                    );
                  }
                },
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Access the money earning Pomodoro timer from the button below to earn money. You will earn money that is half of your focus minutes value.',
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MoneySettingsScreen(),
                      ),
                    ).then((value) {
                      if (value != null && value) {}
                    });
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                      Size(MediaQuery.of(context).size.width * 0.75, 40),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor:
                    MaterialStateProperty.all(Styles.pomodoroPrimaryColor),
                  ),
                  child: const Text(
                    'Earn Money using Pomodoro Timer',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              Text(
                'Badges Store:',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              Text(
                'Purchase badges and equip them one at a time as per your choice!',
                style: TextStyle(fontSize: 15.0),
              ),
              const SizedBox(height: 10.0),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      final badge = badges[index];
                      return ListTile(
                        title: Text(badge.name),
                        subtitle: Text('Price: \¥${badge.price}'),
                        trailing: badge.id == equippedBadge
                            ? ElevatedButton(
                          onPressed: () => _unequipBadge(context, badge),
                          child: const Text('Unequip'),
                        )
                            : ElevatedButton(
                          onPressed: () => _purchaseBadge(context, badge),
                          child: const Text('Purchase'),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _purchaseBadge(BuildContext context, StoreBadge badge) async {
    if (await widget.store.canPurchaseBadge(badge)) {
      await widget.store.purchaseBadge(badge);
      // Update the badge status in Firestore
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({'myBadge': badge.id});
      if (mounted) {
        setState(() {
          equippedBadge = badge.id;
          // Update the badges list to reflect the change
          badges = widget.store.getAvailableBadges();
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Badge ${badge.name} successfully purchased!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You do not have enough money to purchase ${badge.name} :('),
        ),
      );
    }
  }

  Future<void> _unequipBadge(BuildContext context, StoreBadge badge) async {
    // Update the badge status in Firestore
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({'myBadge': 'None'});
    if (mounted) {
      setState(() {
        equippedBadge = 'None';
        // Update the badges list to reflect the change
        badges = widget.store.getAvailableBadges();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Badge ${badge.name} unequipped!'),
        ),
      );
    }
  }

}
