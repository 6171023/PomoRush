class AuthUser {
  DateTime createdAt;
  String? id;
  bool isActive;
  String displayName;
  String photoURL;
  String email;
  double myPoints;
  double myMoney;
  String? myBadge;
  List<String> purchasedBadges;
  final String? myBadgeImagePath;

  AuthUser(
      {required this.createdAt,
        this.id,
        required this.isActive,
        required this.displayName,
        required this.email,
        required this.photoURL,
        required this.myPoints,
        required this.myMoney,
        required this.purchasedBadges,
        required this.myBadge,
        this.myBadgeImagePath,
      });

  toJson() => {
    "displayName": displayName,
    "isActive": isActive,
    "email": email,
    "created_at": createdAt.toString(),
    "myPoints": myPoints,
    "myMoney": myMoney,
    "photoURL": photoURL,
    "myBadge": myBadge,
    "BadgeList": purchasedBadges
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
      createdAt: DateTime.now(),
      isActive: json["isActive"],
      email: json["email"],
      displayName: json["displayName"],
      photoURL: json["photoURL"],
      myPoints: json["myPoints"],
      myMoney: json["myMoney"],
      myBadge: json["myBadge"],
      myBadgeImagePath: json['myBadgeImagePath'],
      purchasedBadges: List<String>.from(json["BadgeList"] ?? []),
  );
}
