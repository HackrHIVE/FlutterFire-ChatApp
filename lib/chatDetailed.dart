import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatDetailed extends StatefulWidget {
  String chatId;
  ChatDetailed({this.chatId});
  @override
  _ChatDetailedState createState() => _ChatDetailedState();
}

class _ChatDetailedState extends State<ChatDetailed> {
  String myId, yourId;
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      setState(() {
        myId = user.uid.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String chatId = widget.chatId;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('chats')
            .document(chatId)
            .collection('messages')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) return buildChat(context, snapshot);
          return Center(
            child: Text('Loading...'),
          );
        },
      ),
    );
  }

  Widget buildChat(BuildContext context, AsyncSnapshot snapshot) {
    return snapshot.hasData
        ? ListView.builder(
            itemCount: snapshot.data.documents.length,
            reverse: true,
            itemBuilder: (context, index) {
              DocumentSnapshot message = snapshot.data.documents[index];
              return message.data['from'] == myId
                  ? myMessage(message, context)
                  : yourMessage(message, context);
            },
          )
        : Container();
  }

  Widget myMessage(DocumentSnapshot message, BuildContext context) {
    //Right
    Timestamp time = message.data['time'];
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      color: Colors.amber,
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            message.data['message'].toString(),
            style: TextStyle(fontSize: 16),
          ),
          Text(
            time.toDate().day.toString() +
                ', ' +
                time.toDate().month.toString(),
            style: TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }

  Widget yourMessage(DocumentSnapshot message, BuildContext context) {
    //Left
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Container(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.data['message'].toString(),
              style: TextStyle(fontSize: 16),
            ),
            Text(
              message.data['time'].toString(),
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
