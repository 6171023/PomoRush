import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  @override
  _LeaderBoardState createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  late List<int> topRankedIndices;

  @override
  void initState() {
    super.initState();
    topRankedIndices = [];
  }

  @override
  Widget build(BuildContext context) {
    var r = const TextStyle(color: Colors.black, fontSize: 34);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 15.0, top: 10.0),
          child: RichText(
            text: const TextSpan(
              text: "Leader Board",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Flexible(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('myPoints', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                updateTopRankedIndices(snapshot.data!);

                return ListView.builder(
                  itemCount: snapshot.data!.size,
                  itemBuilder: (context, index) {
                    bool isTopRanked = topRankedIndices.contains(index);
                    Color borderColor = Colors.amber;

                    if (isTopRanked) {
                      switch (topRankedIndices.indexOf(index)) {
                        case 0:
                          borderColor = Colors.amber;
                          break;
                        case 1:
                          borderColor = Colors.grey;
                          break;
                        case 2:
                          borderColor = Colors.brown;
                          break;
                        default:
                          borderColor = Colors.transparent;
                          break;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 5.0,
                      ),
                      child: InkWell(
                        child: SizedBox(
                          height: 55.0,
                          child: Container(
                            decoration: BoxDecoration(
                              border: isTopRanked
                                  ? Border.all(
                                color: borderColor,
                                width: 3.0,
                                style: BorderStyle.solid,
                              )
                                  : null,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 15.0,
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          snapshot.data!.docs[index]["photoURL"],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 20.0,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            snapshot.data!.docs[index]['displayName'],
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            maxLines: 6,
                                          ),
                                          Text(
                                            "Points: ${snapshot.data!.docs[index]['myPoints']}",
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(),
                                    ),
                                    if (isTopRanked)
                                      Text(
                                        getRankEmoji(topRankedIndices.indexOf(index)),
                                        style: r,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void updateTopRankedIndices(QuerySnapshot snapshot) {
    topRankedIndices.clear();
    for (int index = 0; index < snapshot.docs.length; index++) {
      if (getRankEmoji(index).isNotEmpty) {
        topRankedIndices.add(index);
      }
    }
  }

  String getRankEmoji(int rankIndex) {
    switch (rankIndex) {
      case 0:
        return "🥇";
      case 1:
        return "🥈";
      case 2:
        return "🥉";
      default:
        return "";
    }
  }
}

