import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Helper/Database.dart';
import 'Helper/OfflineStore.dart';

class ChatDetailed extends StatefulWidget {
  String userId;
  ChatDetailed({this.userId});
  @override
  _ChatDetailedState createState() => _ChatDetailedState();
}

class _ChatDetailedState extends State<ChatDetailed> {
  String myId, userId;
  TextEditingController messageController;
  Timestamp past = new Timestamp.fromDate(new DateTime(2019));
  DatabaseHelper dbHelper;
  String chatId;
  OfflineStorage offlineStorage;
  @override
  void initState() {
    super.initState();
    messageController = new TextEditingController();
    dbHelper = new DatabaseHelper();
    offlineStorage = new OfflineStorage();
    offlineStorage.getUserInfo().then((val) {
      setState(() {
        Map<dynamic, dynamic> user = val;
        userId = widget.userId;
        myId = user['uid'].toString();
        chatId = dbHelper.generateChatId(myId, userId);
        print("generated chatID : " + chatId.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: _chatBody(userId),
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
            onPressed: () async {
              String message = messageController.text;
              messageController.clear();
              // bool exists = await dbHelper.checkChatExistsOrNot(userId, myId);
              // if (!exists) {
              // } else {
              //   await Firestore.instance
              //       .collection('chats')
              //       .document(chatId)
              //       .collection('messages')
              //       .add(
              //     {'from': myId, 'message': message, 'time': Timestamp.now()},
              //   );
              //   print('sent!');
              // }
              await dbHelper.sendMessage(userId, myId, message);
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

/*
pSoJeGqd7FfAjLBEPdXwF3c10ou1
Qa7SHEdqJNM36uamJ4NuhRZ6hxf2
*/
  StreamBuilder<QuerySnapshot> _chatBody(String userId) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('chats')
          .document(dbHelper.generateChatId(userId, myId))
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return snapshot.data.documents.length != 0
              ? ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot message = snapshot.data.documents[index];
                    if (index == 0) {
                      past = message.data['time'];
                      return _messageItem(message, context);
                    }
                    Timestamp toPass = past;
                    if (index == snapshot.data.documents.length - 1)
                      return Column(
                        children: [
                          _timeDivider(message.data['time']),
                          _messageItem(message, context),
                          _timeDivider(toPass),
                        ],
                      );
                    past = message.data['time'];
                    return sameDay(message.data['time'], toPass)
                        ? _messageItem(message, context)
                        : Column(
                            children: [
                              _messageItem(message, context),
                              _timeDivider(toPass),
                            ],
                          );
                  },
                )
              : Center(child: Text("No messages yet!"));
        return Center(
          child: Text('Loading...'),
        );
      },
    );
  }

  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  Widget _timeDivider(Timestamp time) {
    DateTime t = time.toDate();
    return Text(t.day.toString() + ' ' + months.elementAt(t.month - 1));
  }

  bool sameDay(Timestamp present, Timestamp passt) {
    DateTime pastTime = passt.toDate();
    DateTime presentTime = present.toDate();
    if (pastTime.year < presentTime.year) return false;
    if (pastTime.month < presentTime.month) return false;
    print("pastDay: " + pastTime.day.toString());
    print("presentDay: " + presentTime.day.toString());
    return pastTime.day == presentTime.day;
  }

  Widget _messageItem(DocumentSnapshot message, BuildContext context) {
    final bool isMe = message.data['from'] == myId;
    Timestamp time = message.data['time'];
    DateTime ttime = time.toDate();
    String minute = ttime.minute > 9
        ? ttime.minute.toString()
        : '0' + ttime.minute.toString();
    String ampm = ttime.hour >= 12 ? "PM" : "AM";
    int hour = ttime.hour >= 12 ? ttime.hour % 12 : ttime.hour;
    int date = ttime.day;
    int month = ttime.month;
    int year = ttime.year;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
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
              hour.toString() +
                  ":" +
                  minute.toString() +
                  " " +
                  ampm +
                  ', ' +
                  date.toString() +
                  ' ' +
                  months[month - 1] +
                  ' ' +
                  year.toString(),
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
      ),
    );
  }
}
