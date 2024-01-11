class AuthUser {
  String? id;
  String displayName;
  String photoURL;
  String email;
  bool isActive;
  double myPoints;
  double myMoney;
  String badge;
  DateTime createdAt;

  AuthUser(
      {required this.createdAt,
        this.id,
        required this.isActive,
        required this.displayName,
        required this.email,
        required this.photoURL,
        required this.myPoints,
        required this.myMoney,
        required this.badge
      });

  toJson() => {
    "displayName": displayName,
    "isActive": isActive,
    "email": email,
    "created_at": createdAt.toString(),
    "myPoints": myPoints,
    "myMoney": myMoney,
    "photoURL": photoURL,
    "myBadge": badge
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
      createdAt: DateTime.now(),
      isActive: json["isActive"],
      myPoints: double.parse(json["myPoints"].toString()),
      myMoney: double.parse(json["myMoney"].toString()),
      email: json["email"],
      photoURL: json["photoURL"],
      displayName: json["displayName"],
      badge: json["badge"]
  );
}