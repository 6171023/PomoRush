import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoreBadge {
  final String id;
  final String name;
  final double price;

  StoreBadge({
    required this.id,
    required this.name,
    required this.price,
  });
}

class Store {
  late List<StoreBadge> _availableBadges;
  late List<StoreBadge> _userBadges;
  late double _userMoney;

  Store() {
    // Initialize available badges in the store
    _availableBadges = [
      StoreBadge(id: '1', name: 'Badge 1', price: 10.0),
      StoreBadge(id: '2', name: 'Badge 2', price: 15.0),
      StoreBadge(id: '3', name: 'Badge 3', price: 20.0),
      // Add more badges as needed
    ];

    // Fetch user's money from Firebase and set it as the initial value
    _fetchUserMoney().then((double money) {
      _userMoney = money;
    });

    // Initialize user's purchased badges
    _userBadges = [];
  }

  List<StoreBadge> getAvailableBadges() {
    return _availableBadges;
  }

  List<StoreBadge> getUserBadges() {
    return _userBadges;
  }

  double getUserMoney() {
    return _userMoney;
  }

  bool canPurchaseBadge(StoreBadge badge) {
    return _userMoney >= badge.price;
  }

  void purchaseBadge(StoreBadge badge) {
    if (canPurchaseBadge(badge)) {
      // Deduct money and add badge to the user's collection
      _userMoney -= badge.price;
      _userBadges.add(badge);
    }
  }

  // Fetch user's money from Firebase
  Future<double> _fetchUserMoney() async {
    double money = 0.0; // Default value if fetching fails
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot snapshot = await users.where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).get();
    if (snapshot.docs.isNotEmpty) {
      money = double.parse(snapshot.docs.first["myMoney"].toString());
    }
    return money;
  }
}