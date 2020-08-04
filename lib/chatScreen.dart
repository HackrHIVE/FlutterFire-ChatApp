import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chatapp/auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Future<List<DocumentSnapshot>> getList(lisChat) async {
    List<DocumentSnapshot> chatList = new List<DocumentSnapshot>();
    for (int i = 0; i < lisChat.length; i++) {
      String x = lisChat[i];
      print('Chat id : ' + x.toString());
      await Firestore.instance.collection('chats').document(x).get().then(
        (value) {
          print(x.toString() +
              ' :: ' +
              'isGroup : ' +
              value.data['isGroup'].toString());
          chatList.add(value);
          print('new length : ' + chatList.length.toString());
          if (i == lisChat.length - 1) {
            print('length before returning : ' + chatList.length.toString());
            return chatList;
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                print(snapshotChat.data.toString());
                return (snapshotChat.data.documents.length == 0)
                    ? Center(
                        child: Text('No Chats'),
                      )
                    : ListView.builder(
                        itemCount: snapshotChat.data.documents.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot dSnap =
                              snapshotChat.data.documents[index];
                          return Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.orange),
                            margin: EdgeInsets.all(10.0),
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            child: Center(
                              child: Text(
                                dSnap.documentID.toString(),
                              ),
                            ),
                          );
                        },
                      );
              }
              return Center(
                child: Text('Loading Chats...'),
              );
            },
          );
        } else
          return Center(
            child: Text('Loading Chats...'),
          );
      },
    );
  }
}
