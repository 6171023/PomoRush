import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoreBadge {
  final String name;
  final double price;
  bool isEquipped;
  bool isPurchased;

  StoreBadge({
    required this.name,
    required this.price,
    this.isEquipped = false,
    this.isPurchased = false,
  });

  factory StoreBadge.fromMap(Map<String, dynamic> map) {
    return StoreBadge(
      name: map['name'],
      price: map['price'].toDouble(),
      isEquipped: map['isEquipped'] ?? false,
      isPurchased: map['isPurchased'] != null && map['isPurchased']['_seconds'] > 0,
    );
  }

}

class Store {
  late List<StoreBadge> _availableBadges;
  late List<StoreBadge> _userBadges;
  List<String> _userPurchasedBadgeIds = [];

  Store() {
    _initializeAvailableBadges();
    _userBadges = [];
    initUserBadges();
  }

  void _initializeAvailableBadges() {
    _availableBadges = [
      StoreBadge(name: 'Badge 1', price: 1.0),
      StoreBadge(name: 'Badge 2', price: 2.0),
      StoreBadge(name: 'Badge 3', price: 3.0),
      // Add more badges as needed
    ];
  }

  Future<void> initUserBadges() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    DocumentSnapshot doc = await users.doc(FirebaseAuth.instance.currentUser!.uid).get();

    // Check if the document exists and if "BadgeList" field exists
    if (doc.exists && doc.data() != null) {
      var data = doc.data() as Map<String, dynamic>;

      if (data.containsKey('BadgeList')) {
        var badgeList = List<String>.from(data['BadgeList']);
        var myBadge = data['myBadge'];

        // Initialize _availableBadges and _userBadges
        _initializeAvailableBadges();
        _userBadges = [];

        // Iterate over _availableBadges and set isPurchased and isEquipped based on badgeList and myBadge
        for (var badge in _availableBadges) {
          if (badgeList.contains(badge.name)) {
            _userBadges.add(badge);
            badge.isPurchased = true;
            if (badge.name == myBadge) {
              badge.isEquipped = true;
            }
          }
        }

        // Update _availableBadges based on Firebase data
        for (var badge in _userBadges) {
          if (!badgeList.contains(badge.name)) {
            // If the badge is not in BadgeList, mark it as not purchased
            badge.isPurchased = false;
          }
        }
      } else {
        // Handle the case when "BadgeList" is not present in the document
        print('BadgeList is not present in the document.');
      }
    } else {
      // Handle the case when the document does not exist
      print('Document does not exist.');
    }
  }



  List<StoreBadge> getAvailableBadges() {
    return _availableBadges;
  }

  List<StoreBadge> getUserBadges() {
    return _userBadges;
  }

  Future<bool> canPurchaseBadge(StoreBadge badge) async {
    double money = await fetchUserMoney().first;
    return money >= badge.price;
  }

  Future<bool> purchaseBadge(StoreBadge badge) async {
    if (await canPurchaseBadge(badge)) {
      _deductUserMoney(badge.price);
      _userBadges.add(badge);

      // Update the purchasedBadges field in the user document
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      QuerySnapshot snapshot = await users.where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).get();
      if (snapshot.docs.isNotEmpty) {
        await users.doc(snapshot.docs.first.id).update({
          "BadgeList": FieldValue.arrayUnion([badge.name])
        });
      }

      return true; // Indicate that the purchase was successful
    } else {
      return false; // Indicate that the purchase failed
    }
  }



  Future<void> equipBadge(StoreBadge badge) async {
    if (_userBadges.contains(badge)) {
      badge.isEquipped = true;
      badge.isPurchased = true;
      // Update badge status in Firestore
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      QuerySnapshot snapshot = await users.where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).get();
      if (snapshot.docs.isNotEmpty) {
        await users.doc(snapshot.docs.first.id).update({
          "myBadge": badge.name,
          "BadgeList": FieldValue.arrayUnion([badge.name])
        });
      }
    }
  }

  Future<void> unequipBadge(StoreBadge badge) async {
    if (_userBadges.contains(badge)) {
      badge.isEquipped = false;
      badge.isPurchased = true;
      // Update badge status in Firestore
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      QuerySnapshot snapshot = await users.where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).get();
      if (snapshot.docs.isNotEmpty) {
        await users.doc(snapshot.docs.first.id).update({
          "myBadge": "None",
        });
      }
    }
  }


  Stream<double> fetchUserMoney() {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .snapshots()
        .map((snapshot) => double.parse(snapshot.docs.first["myMoney"].toString()));
  }

  Stream<String> fetchUserBadge() {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty
        ? snapshot.docs.first["myBadge"].toString()
        : "None");
  }

  Stream<List<String>> fetchUserBadgeList() {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .snapshots()
        .map((snapshot) {
      // Use safe navigation to avoid null errors
      var badgeList = snapshot.docs.first["BadgeList"] as List<String>?;

      // Return an empty list if badgeList is null
      return badgeList ?? [];
    });
  }



  void _deductUserMoney(double amount) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    try {
      QuerySnapshot snapshot = await users.where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).get();
      if (snapshot.docs.isNotEmpty) {
        await users.doc(snapshot.docs.first.id).update({"myMoney": FieldValue.increment(-amount)});
      }
    } catch (e) {
      print('Failed to deduct money: $e');
      // Handle the error appropriately for your app
    }
  }
}


