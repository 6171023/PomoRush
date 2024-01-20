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

  AuthUser(
      {required this.createdAt,
        this.id,
        required this.isActive,
        required this.displayName,
        required this.email,
        required this.photoURL,
        required this.myPoints,
        required this.myMoney,
        this.myBadge});

  toJson() => {
    "displayName": displayName,
    "isActive": isActive,
    "email": email,
    "created_at": createdAt.toString(),
    "myPoints": myPoints,
    "myMoney": myMoney,
    "photoURL": photoURL,
    "myBadge": myBadge,
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
      createdAt: DateTime.now(),
      isActive: json["isActive"],
      myPoints: json["myPoints"],
      myMoney: json["myMoney"],
      email: json["email"],
      photoURL: json["photoURL"],
      displayName: json["displayName"],
      myBadge: json["myBadge"]);
}
