import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chatapp/chatDetailed.dart';
import 'package:flutter/material.dart';

import 'Helper/Database.dart';
import 'Helper/OfflineStore.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  DatabaseHelper dbHelper;
  OfflineStorage offlineStorage;
  @override
  void initState() {
    super.initState();
    setState(() {
      dbHelper = new DatabaseHelper();
      offlineStorage = new OfflineStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        splashColor: Theme.of(context).colorScheme.onSecondary,
        child: Icon(
          Icons.add,
        ),
      ),
      body: FutureBuilder(
        future: dbHelper.getChats(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            QuerySnapshot qSnap = snapshot.data;
            List<DocumentSnapshot> docs = qSnap.documents;
            if (docs.length == 0)
              return Center(
                child: Text('No Chats yet!'),
              );
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                List<dynamic> members = docs[index].data['members'];
                String userId;
                return FutureBuilder(
                  future: offlineStorage.getUserInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Map<dynamic, dynamic> user = snapshot.data;
                      String myId = user['uid'];
                      userId = members.elementAt(0) == myId
                          ? members.elementAt(1)
                          : members.elementAt(0);
                      print('Setting userId');
                      print('UserId : ' + userId.toString());
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: InkWell(
                          splashColor: Theme.of(context).colorScheme.primary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailed(
                                userId: userId.toString(),
                              ),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(10.0),
                            height: MediaQuery.of(context).size.height * 0.08,
                            child: Center(
                              child: Text(
                                docs[index].documentID.toString(),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
    return StreamBuilder(
      stream: FirebaseAuth.instance.currentUser().asStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          FirebaseUser user = snapshot.data;
          return StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(user.uid)
                .collection('chats')
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshotChat) {
              if (snapshotChat.hasData) {
                return (snapshotChat.data.documents.length == 0)
                    ? Center(
                        child: Text('No Chats'),
                      )
                    : ListView.builder(
                        itemCount: snapshotChat.data.documents.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot dSnap =
                              snapshotChat.data.documents[index];
                          List<dynamic> members = dSnap.data['members'];

                          String userId;
                          return Card(
                            color: Colors.amberAccent,
                            margin: EdgeInsets.all(8.0),
                            elevation: 8.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: InkWell(
                              splashColor: Colors.blueAccent,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailed(
                                    userId: userId,
                                  ),
                                ),
                              ),
                              child: Container(
                                margin: EdgeInsets.all(10.0),
                                height:
                                    MediaQuery.of(context).size.height * 0.08,
                                child: Center(
                                  child: Text(
                                    dSnap.documentID.toString(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
              }
              return Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation(
                    Color(0xff49ffa0),
                  ),
                ),
              );
            },
          );
        } else
          return Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation(
                Color(0xff49ffa0),
              ),
            ),
          );
      },
    );
  }
}
