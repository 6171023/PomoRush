import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  List<bool> equippedBadgeStates = [];

  @override
  void initState() {
    super.initState();
    equippedBadgeStates = widget.store.getAvailableBadges().map((badge) => badge.isEquipped).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
                    'Your Money: \¥${snapshot.data}',
                    style: TextStyle(fontSize: 18.0),
                  );
                }
              },
            ),
            StreamBuilder<String>(
              stream: widget.store.fetchUserBadge(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(
                    'Currently equipped badge: ${snapshot.data}',
                    style: TextStyle(fontSize: 18.0),
                  );
                }
              },
            ),
            const SizedBox(height: 10.0),
            Text(
              'Access the money earning Pomodoro timer from the button below to earn money. You will earn money that is half of your focus minutes value.',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 15.0),
            ),
            const SizedBox(height: 10.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MoneySettingsScreen(),
                    ),
                  ).then((value) {
                    if (value != null && value) {
                      setState(() {
                        // Update the UI after a badge is purchased
                      });
                    }
                  });
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                      Size(MediaQuery
                          .of(context)
                          .size
                          .width * 0.75, 40)),
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
                  'Earn Money',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Your Badge Store:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: widget.store
                    .getAvailableBadges()
                    .length,
                itemBuilder: (context, index) {
                  final badge = widget.store.getAvailableBadges()[index];
                  return ListTile(
                    title: Text(badge.name),
                    subtitle: Text('Price: \¥${badge.price}'),
                    trailing: _buildBadgeButton(context, badge, index),
                  );
                },
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeButton(BuildContext context, StoreBadge badge, int index) {
    bool isBadgePurchased = badge.isPurchased;
    bool isBadgeEquipped = badge.isEquipped;

    if (isBadgePurchased && isBadgeEquipped) {
      return ElevatedButton(
        onPressed: () async {
          // Unequip the badge
          await _unequipBadge(context, badge);
          setState(() {});
        },
        child: Text('Unequip'),
      );
    } else if (isBadgePurchased && !isBadgeEquipped) {
      return ElevatedButton(
        onPressed: () async {
          // Equip the badge
          await _equipBadge(context, badge);
          setState(() {});
        },
        child: Text('Equip'),
      );
    } else {
      return ElevatedButton(
        onPressed: () async {
          // Purchase the badge
          bool purchaseSuccess = await _purchaseBadge(context, badge);
          if (purchaseSuccess) {
            setState(() {});
          }
        },
        child: Text('Purchase'),
      );
    }
  }



  Future<void> _equipBadge(BuildContext context, StoreBadge badge) async {
    widget.store.equipBadge(badge);
    badge.isEquipped = true; // Equip the badge
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Badge ${badge.name} equipped!'),
      ),
    );
    // Return an empty Future to satisfy the return type
    return Future.value();
  }

  Future<void> _unequipBadge(BuildContext context, StoreBadge badge) async {
    widget.store.unequipBadge(badge);
    badge.isEquipped = false; // Unequip the badge
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Badge ${badge.name} unequipped!'),
      ),
    );
    // Return an empty Future to satisfy the return type
    return Future.value();
  }




  Future<bool> _purchaseBadge(BuildContext context, StoreBadge badge) async {
    if (await widget.store.canPurchaseBadge(badge)) {
      bool purchaseSuccess = await widget.store.purchaseBadge(badge);
      if (purchaseSuccess) {
        badge.isPurchased = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Badge ${badge.name} purchased!'),
          ),
        );
        setState(() {});
        return true; // Indicate that the purchase was successful
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Not enough money to purchase ${badge.name} :('),
          ),
        );
        return false; // Indicate that the purchase failed
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oops! Not enough to purchase ${badge.name} :( Earn enough money by using the timer!'),
        ),
      );
      return false; // Indicate that the purchase cannot be made
    }
  }


}
