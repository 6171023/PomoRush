import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoreBadge {
  final String name;
  final double price;
  final String imagePath;
  bool isEquipped;
  bool isPurchased;

  StoreBadge({
    required this.name,
    required this.price,
    required this.imagePath,
    this.isEquipped = false,
    this.isPurchased = true,
  });

  factory StoreBadge.fromMap(Map<String, dynamic> map) {
    return StoreBadge(
      name: map['name'],
      price: map['price'].toDouble(),
      imagePath: map['image'],
      isEquipped: map['isEquipped'] ?? false,
      isPurchased: map['isPurchased'] ?? false,
    );
  }

}

class Store {
  late List<StoreBadge> _availableBadges;
  late List<StoreBadge> _userBadges;

  Store() {
    _initializeAvailableBadges();
    _userBadges = [];
    initUserBadges();
  }

  void _initializeAvailableBadges() {
    _availableBadges = [
      StoreBadge(name: 'Beginner', price: 100.0, imagePath: 'assets/beginner.png', isEquipped: false, isPurchased: false),
      StoreBadge(name: 'Advanced', price: 500.0, imagePath: 'assets/advanced.png', isEquipped: false, isPurchased: false),
      StoreBadge(name: 'Elite', price: 1000.0, imagePath: 'assets/elite.png', isEquipped: false, isPurchased: false),
      StoreBadge(name: 'Pro', price: 1500.0, imagePath: 'assets/pro.png', isEquipped: false, isPurchased: false),
      StoreBadge(name: 'Master', price: 2000.0, imagePath: 'assets/master.png', isEquipped: false, isPurchased: false),
      StoreBadge(name: 'Grandmaster', price: 2500.0, imagePath: 'assets/grandmaster.png', isEquipped: false, isPurchased: false),
      StoreBadge(name: 'Legendary', price: 3000.0, imagePath: 'assets/legendary.png', isEquipped: false, isPurchased: false),
    ];
  }

  Future<void> initUserBadges() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot snapshot = await users.where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).get();

    if (snapshot.docs.isNotEmpty) {
      for (DocumentSnapshot doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('BadgeList')) {
          var badgeList = List<String>.from(data['BadgeList']);
          var myBadge = data['myBadge'];

          _initializeAvailableBadges();
          _userBadges = [];

          for (var badge in _availableBadges) {
            if (badgeList.contains(badge.name)) {
              badge.isPurchased = true;
              _userBadges.add(badge);

              if (myBadge == badge.name) {
                badge.isEquipped = true;
              }
            } else {
              badge.isPurchased = false;
            }
          }
        } else {
          print('BadgeList is not present in the document.');
        }
      }
    } else {
      print('No documents found for the current user.');
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

      CollectionReference users = FirebaseFirestore.instance.collection('users');
      QuerySnapshot snapshot = await users.where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).get();
      if (snapshot.docs.isNotEmpty) {
        await users.doc(snapshot.docs.first.id).update({
          "BadgeList": FieldValue.arrayUnion([badge.name])
        });
      }

      return true;
    } else {
      return false;
    }
  }



  Future<void> equipBadge(StoreBadge badge) async {
    if (_userBadges.contains(badge)) {
      for (var b in _userBadges) {
        b.isEquipped = false;
      }

      badge.isEquipped = true;

      String? badgeImagePath = badge.isPurchased ? '${badge.imagePath}' : null;

      CollectionReference users = FirebaseFirestore.instance.collection('users');
      QuerySnapshot snapshot =
      await users.where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).get();
      if (snapshot.docs.isNotEmpty) {
        await users.doc(snapshot.docs.first.id).update({
          "myBadge": badge.name,
          "BadgeList": FieldValue.arrayUnion([badge.name]),
          "myBadgeImagePath": badgeImagePath,
        });
      }
    }
  }



  Future<void> unequipBadge(StoreBadge badge) async {
    if (_userBadges.contains(badge)) {
      badge.isEquipped = false;
      badge.isPurchased = true;
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      QuerySnapshot snapshot = await users.where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).get();
      if (snapshot.docs.isNotEmpty) {
        await users.doc(snapshot.docs.first.id).update({
          "myBadge": "None",
          "myBadgeImagePath": null,
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
      var badgeList = snapshot.docs.first["BadgeList"] as List<String>?;

      return badgeList ?? [];
    });
  }

  Stream<String?> fetchUserBadgeImage() {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var myBadge = snapshot.docs.first["myBadge"];
        if (myBadge != "None") {
          return snapshot.docs.first["myBadgeImagePath"].toString();
        }
      }
      return "None";
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
    }
  }
}

