import 'package:firebase_auth/firebase_auth.dart';

class Challenge {
  String id;
  String acceptorDisplayName;
  String requesterDisplayName;
  String acceptorEmail;
  String acceptorEndTime;
  String challengeEndTime;
  String challengeStartTime;
  String requesterEmail;
  String requesterEndTime;
  String status;
  String startedBy;
  double acceptorPoints;
  double requesterPoint;

  int breakTime;
  int focusTime;
  int setCount;

  String acceptorCurrentTimer;
  String requesterCurrentTimer;
  String acceptorCurrentState;
  String requesterCurrentState;

  String requesterState;

  String acceptorState;

  Challenge(
      {required this.id,
        required this.acceptorDisplayName,
        required this.acceptorEmail,
        required this.acceptorEndTime,
        required this.breakTime,
        required this.challengeEndTime,
        required this.challengeStartTime,
        required this.focusTime,
        required this.requesterDisplayName,
        required this.requesterEmail,
        required this.requesterEndTime,
        required this.setCount,
        required this.status,
        required this.startedBy,
        required this.acceptorPoints,
        required this.requesterPoint,
        required this.acceptorCurrentTimer,
        required this.requesterCurrentTimer,
        required this.acceptorCurrentState,
        required this.requesterCurrentState,
        required this.requesterState,
        required this.acceptorState});

  toJson() => {
    "id": id,
    "acceptorDisplayName": acceptorDisplayName,
    "requesterDisplayName":
    FirebaseAuth.instance.currentUser!.displayName,
    "acceptorEmail": acceptorEmail,
    "acceptorEndTime": acceptorEndTime,
    "breakTime": breakTime,
    "challengeEndTime": challengeEndTime,
    "challengeStartTime": challengeStartTime,
    "focusTime": focusTime,
    "requesterEmail": requesterEmail,
    "requesterEndTime": requesterEndTime,
    "setCount": setCount,
    "status": status,
    "startedBy": startedBy,
    "acceptorPoints": acceptorPoints,
    "requesterPoint": requesterPoint,
    "acceptorCurrentTimer": acceptorCurrentTimer,
    "requesterCurrentTimer": requesterCurrentTimer,
    "acceptorCurrentState": acceptorCurrentState,
    "requesterCurrentState": requesterCurrentState,
    "requesterState": requesterState,
    "acceptorState": acceptorState
  };

  factory Challenge.fromJson(Map<String, dynamic> json, String docId) =>
      Challenge(
          id: docId,
          acceptorDisplayName: json["acceptorDisplayName"],
          acceptorEmail: json["acceptorEmail"],
          acceptorEndTime: json["acceptorEndTime"],
          breakTime: json["breakTime"],
          challengeEndTime: json["challengeEndTime"],
          challengeStartTime: json["challengeStartTime"],
          focusTime: json["focusTime"],
          requesterDisplayName: json["requesterDisplayName"],
          requesterEmail: json["requesterEmail"],
          requesterEndTime: json["requesterEndTime"],
          setCount: json["setCount"],
          status: json["status"],
          startedBy: json["startedBy"],
          acceptorPoints: double.parse(json["acceptorPoints"].toString()),
          requesterPoint: double.parse(json["requesterPoint"].toString()),
          acceptorCurrentTimer: json["acceptorCurrentTimer"].toString(),
          requesterCurrentTimer: json["requesterCurrentTimer"].toString(),
          acceptorCurrentState: json["acceptorCurrentState"],
          requesterCurrentState: json["requesterCurrentState"].toString(),
          requesterState: json["requesterState"],
          acceptorState: json["acceptorState"]);
}
