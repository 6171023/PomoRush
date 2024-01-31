import 'package:flutter/material.dart';
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
            StreamBuilder<String?>(
              stream: widget.store.fetchUserBadgeImage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return StreamBuilder<String>(
                    stream: widget.store.fetchUserBadge(),
                    builder: (context, badgeSnapshot) {
                      if (badgeSnapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (badgeSnapshot.hasError) {
                        return Text('Error: ${badgeSnapshot.error}');
                      } else {
                        if (snapshot.data != null && Uri.tryParse(snapshot.data!) != null && badgeSnapshot.data != "None") {
                          return Row(
                            children: [
                              Text('Equipped badge: ',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              Image.asset(
                                snapshot.data!,
                                width: 40,
                                height: 40,
                              ),
                            ],
                          );
                        } else {
                          return Text('Equipped badge: ${badgeSnapshot.data}',
                            style: TextStyle(fontSize: 18.0),
                          );
                        }
                      }
                    },
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
            const SizedBox(height: 10.0),
            Text(
              'Your Badge Store:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Text(
              'Purchase badges and equip them one at a time as per your choice! Equipped badges will be viewable to other users through the users page.',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 15.0),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xff440D0F), width: 2),
                ),
                child: ListView.builder(
                  itemCount: widget.store.getAvailableBadges().length,
                  itemBuilder: (context, index) {
                    final badge = widget.store.getAvailableBadges()[index];
                    return ListTile(
                      title: Row(
                        children: [
                          Image.asset(
                            badge.imagePath,
                            width: 50,
                            height: 50,
                          ),
                          SizedBox(width: 5),
                          Text(badge.name),
                        ],
                      ),
                      subtitle: Text('Price: \¥${badge.price}'),
                      trailing: _buildBadgeButton(context, badge),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 5.0),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeButton(BuildContext context, StoreBadge badge) {
    bool isBadgePurchased = badge.isPurchased;
    bool isBadgeEquipped = badge.isEquipped;

    if (isBadgePurchased && isBadgeEquipped) {
      return ElevatedButton(
        onPressed: () async {
          await _unequipBadge(context, badge);
          setState(() {});
        },
        child: Text('Unequip'),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(
              Size(MediaQuery.of(context).size.width/3, 30)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          backgroundColor:
          MaterialStateProperty.all(Colors.blueGrey),
        ),
      );
    } else if (isBadgePurchased && !isBadgeEquipped) {
      return ElevatedButton(
        onPressed: () async {
          await _equipBadge(context, badge);
          setState(() {});
        },
        child: Text('Equip'),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(
              Size(MediaQuery.of(context).size.width/3, 30)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          backgroundColor:
          MaterialStateProperty.all(Colors.green),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: () async {
          bool purchaseSuccess = await _purchaseBadge(context, badge);
          if (purchaseSuccess) {
            setState(() {});
          }
        },
        child: Text('PURCHASE'),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(
              Size(MediaQuery.of(context).size.width/3, 30)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          backgroundColor:
          MaterialStateProperty.all(Colors.brown),
        ),
      );
    }
  }



  Future<void> _equipBadge(BuildContext context, StoreBadge badge) async {
    widget.store.equipBadge(badge);
    badge.isEquipped = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Badge ${badge.name} equipped!'),
        duration: const Duration(seconds: 3),
      ),
    );
    return Future.value();
  }

  Future<void> _unequipBadge(BuildContext context, StoreBadge badge) async {
    widget.store.unequipBadge(badge);
    badge.isEquipped = false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Badge ${badge.name} unequipped!'),
        duration: const Duration(seconds: 3),
      ),
    );
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
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {});
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Not enough money to purchase ${badge.name} :('),
            duration: const Duration(seconds: 3),
          ),
        );
        return false;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oops! Not enough to purchase ${badge.name} :( Earn enough money by using the timer!'),
          duration: const Duration(seconds: 3),
        ),
      );
      return false;
    }
  }


}