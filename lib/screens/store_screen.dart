import 'package:flutter/material.dart';
import 'store.dart';

class StoreScreen extends StatelessWidget {
  final Store store;

  const StoreScreen({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Money: \¥${store.getUserMoney()}',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Available Badges:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: store.getAvailableBadges().length,
                itemBuilder: (context, index) {
                  final badge = store.getAvailableBadges()[index];
                  return ListTile(
                    title: Text(badge.name),
                    subtitle: Text('Price: \¥${badge.price}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _purchaseBadge(context, badge);
                      },
                      child: const Text('Purchase'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Your Badges:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: store.getUserBadges().length,
                itemBuilder: (context, index) {
                  final badge = store.getUserBadges()[index];
                  return ListTile(
                    title: Text(badge.name),
                    subtitle: Text('Price: \$${badge.price}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _purchaseBadge(BuildContext context, StoreBadge badge) {
    if (store.canPurchaseBadge(badge)) {
      store.purchaseBadge(badge);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Badge ${badge.name} purchased!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough money to purchase ${badge.name}.'),
        ),
      );
    }
  }
}