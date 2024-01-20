import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoreBadge {
  final String id;
  final String name;
  final double price;
  bool isEquipped;

  StoreBadge({
    required this.id,
    required this.name,
    required this.price,
    this.isEquipped = false,
  });

  factory StoreBadge.fromMap(Map<String, dynamic> map) {
    return StoreBadge(
      id: map['id'],
      name: map['name'],
      price: map['price'].toDouble(),
      isEquipped: map['isEquipped'] ?? false,
    );
  }
}

class Store {
  late List<StoreBadge> _availableBadges;
  late List<StoreBadge> _userBadges;

  Store() {
    _initializeAvailableBadges();
    _initializeUserBadges();
  }

  void _initializeAvailableBadges() {
    _availableBadges = [
      StoreBadge(id: '1', name: 'Badge 1', price: 1.0),
      StoreBadge(id: '2', name: 'Badge 2', price: 2.0),
      StoreBadge(id: '3', name: 'Badge 3', price: 3.0),
      // Add more badges as needed
    ];
  }

  void _initializeUserBadges() async {
    CollectionReference badges = FirebaseFirestore.instance.collection('badges');
    QuerySnapshot snapshot = await badges.where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).get();
    _userBadges = snapshot.docs.map((doc) => StoreBadge.fromMap(doc.data() as Map<String, dynamic>)).toList();
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

  Future<void> purchaseBadge(StoreBadge badge) async {
    if (await canPurchaseBadge(badge)) {
      _deductUserMoney(badge.price);
      _userBadges.add(badge);
      // Update badge status in Firestore
      CollectionReference badges = FirebaseFirestore.instance.collection('badges');
      await badges.doc(badge.id).set({
        "email": FirebaseAuth.instance.currentUser!.email,
        "name": badge.name,
        "price": badge.price,
        "isEquipped": false
      });
    }
  }

  Future<void> equipBadge(StoreBadge badge) async {
    if (_userBadges.contains(badge)) {
      badge.isEquipped = true;
      // Update badge status in Firestore
      CollectionReference badges = FirebaseFirestore.instance.collection('badges');
      await badges.doc(badge.id).set({"isEquipped": true});

      // Equip the badge in AuthUser
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      QuerySnapshot snapshot = await users.where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).get();
      if (snapshot.docs.isNotEmpty) {
        await users.doc(snapshot.docs.first.id).update({"myBadge": badge.id});
      }
    }
  }

  Future<void> unequipBadge(StoreBadge badge) async {
    if (_userBadges.contains(badge)) {
      badge.isEquipped = false;
      // Update badge status in Firestore
      CollectionReference badges = FirebaseFirestore.instance.collection('badges');
      await badges.doc(badge.id).set({"isEquipped": false});

      // Unequip the badge in AuthUser
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      QuerySnapshot snapshot = await users.where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email).get();
      if (snapshot.docs.isNotEmpty) {
        await users.doc(snapshot.docs.first.id).update({"myBadge": "None"});
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
