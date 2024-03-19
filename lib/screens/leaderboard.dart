// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  @override
  _LeaderBoardState createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  int i = 0;
  Color my = Colors.brown, checkMyColor = Colors.white;

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
                      fontWeight: FontWeight.bold),
                  )),
        ),
        Flexible(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('myPoints', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    i = 0;
                    return ListView.builder(
                        itemCount: snapshot.data!.size,
                        itemBuilder: (context, index) {
                          if (index >= 1) {
                            if (snapshot.data!.docs[index]["myPoints"] ==
                                snapshot.data!.docs[index - 1]["myPoints"]) {
                            } else {
                              i++;
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 5.0),
                            child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: i == 0
                                            ? Colors.amber
                                            : i == 1
                                            ? Colors.grey
                                            : i == 2
                                            ? Colors.brown
                                            : Colors.transparent,
                                        width: 3.0,
                                        style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(5.0)),
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15.0),
                                          child: Row(
                                            children: <Widget>[
                                              CircleAvatar(
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          image: DecorationImage(
                                                              image: NetworkImage(snapshot.data!.docs[index]["photoURL"]),
                                                              fit: BoxFit.fill)))),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20.0),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                  alignment:
                                                  Alignment.centerLeft,
                                                  child: Text(snapshot.data!.docs[index]['displayName'],
                                                    style: const TextStyle(
                                                        color:
                                                        Colors.black,
                                                        fontWeight:
                                                        FontWeight.w800),
                                                    maxLines: 6,
                                                  )),
                                              Text(
                                                  "Points: ${snapshot.data!.docs[index]['myPoints']}"),
                                            ],
                                          ),
                                        ),
                                        Flexible(child: Container()),
                                        i == 0
                                            ? Text("🥇", style: r)
                                            : i == 1
                                            ? Text(
                                          "🥈",
                                          style: r,
                                        )
                                            : i == 2
                                            ? Text(
                                          "🥉",
                                          style: r,
                                        )
                                            : const Text(''),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }))
      ],
    );
  }
}