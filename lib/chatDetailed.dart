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
  TextEditingController messageController;
  @override
  void initState() {
    super.initState();
    messageController = new TextEditingController();
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
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: _chatBody(chatId),
            ),
            new Divider(
              height: 1.0,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.10,
              child: _messageComposer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageComposer() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.image,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: messageController,
              decoration: new InputDecoration(
                border: new OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
                focusedBorder: new OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
                enabledBorder: new OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
                errorBorder: new OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
                filled: true,
                hintText: "Type in your message",
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FloatingActionButton(
            onPressed: () {
              print("Message is : " + messageController.text);
              messageController.clear();
            },
            child: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
      ],
    );
  }

  StreamBuilder<QuerySnapshot> _chatBody(String chatId) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('chats')
          .document(chatId)
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot message = snapshot.data.documents[index];
                    return messageItem(message, context);
                    // ? myMessage(message, context)
                    // : yourMessage(message, context);
                  },
                )
              : Container();
        return Center(
          child: Text('Loading...'),
        );
      },
    );
  }

  Widget messageItem(DocumentSnapshot message, BuildContext context) {
    final bool isMe = message.data['from'] == myId;
    Timestamp time = message.data['time'];
    print('time is ' + time.toDate().toString());
    String minute = time.toDate().minute > 9
        ? time.toDate().minute.toString()
        : '0' + time.toDate().minute.toString();
    String ampm = time.toDate().hour >= 12 ? "PM" : "AM";
    int hour =
        time.toDate().hour >= 12 ? time.toDate().hour % 12 : time.toDate().hour;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      margin: isMe
          ? EdgeInsets.only(
              left: 80.0,
              bottom: 8.0,
              top: 8.0,
            )
          : EdgeInsets.only(
              right: 80.0,
              bottom: 8.0,
              top: 8.0,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hour.toString() + ":" + minute.toString() + " " + ampm,
            style: TextStyle(
              color: Color(0xfff0f696),
              fontSize: 12.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            message.data['message'].toString(),
            style: TextStyle(
              color: isMe
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).colorScheme.onPrimary,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: isMe
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.secondaryVariant,
        borderRadius: isMe
            ? BorderRadius.only(
                topLeft: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
              )
            : BorderRadius.only(
                topRight: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              ),
      ),
    );
  }
}
