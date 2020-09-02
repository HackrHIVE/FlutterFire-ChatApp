import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chatapp/imageViewer.dart';
import 'package:firebase_chatapp/profileScreen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'Helper/Database.dart';
import 'Helper/OfflineStore.dart';

class ChatDetailed extends StatefulWidget {
  Map<String, dynamic> userData;
  ChatDetailed({this.userData});
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
  Map<String, dynamic> userData;
  final _scaffKey = GlobalKey<ScaffoldState>();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    messageController = new TextEditingController();
    dbHelper = new DatabaseHelper();
    offlineStorage = new OfflineStorage();
    offlineStorage.getUserInfo().then(
      (val) {
        setState(
          () {
            Map<dynamic, dynamic> user = val;
            userId = widget.userData['uid'].toString();
            myId = user['uid'].toString();
            chatId = dbHelper.generateChatId(myId, userId);
            userData = widget.userData;
            print("caught User : " + userData['name'].toString());
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffKey,
      body: Column(
        children: [
          AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    userData: userData,
                  ),
                ),
              ),
              splashColor: Theme.of(context).colorScheme.primary,
              focusColor: Theme.of(context).colorScheme.primary,
              highlightColor: Theme.of(context).colorScheme.primary,
              hoverColor: Theme.of(context).colorScheme.primary,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Row(
                  children: [
                    Hero(
                      tag: userData['photo'].toString(),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.1,
                        height: MediaQuery.of(context).size.width * 0.1,
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: new NetworkImage(
                              userData['photo'].toString(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Text(
                      userData['name'].toString(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    )
                  ],
                ),
              ),
            ),
          ),
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
    );
  }

  Widget _messageComposer() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => showDialog(
              // barrierDismissible: false,
              context: context,
              builder: (context) => _buildPopUpImagePicker(context),
            ),
            child: Icon(
              Icons.image,
              color: Theme.of(context).colorScheme.secondary,
            ),
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
              if (message.isNotEmpty) {
                messageController.clear();
                await dbHelper.sendMessage(
                    to: userId, from: myId, isText: true, msg: message);
              }
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

  StreamBuilder<QuerySnapshot> _chatBody(String userId) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(dbHelper.generateChatId(userId, myId))
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return snapshot.data.docs.length != 0
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot message = snapshot.data.docs[index];
                    if (snapshot.data.docs.length == 1)
                      return Column(
                        children: [
                          _timeDivider(message.data()['time']),
                          _messageItem(message, context),
                        ],
                      );
                    if (index == 0) {
                      past = message.data()['time'];
                      return _messageItem(message, context);
                    }
                    Timestamp toPass = past;
                    if (index == snapshot.data.docs.length - 1)
                      return Column(
                        children: [
                          _timeDivider(message.data()['time']),
                          _messageItem(message, context),
                          if (!sameDay(toPass, message.data()['time']))
                            _timeDivider(toPass),
                        ],
                      );
                    past = message.data()['time'];
                    return sameDay(message.data()['time'], toPass)
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
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  Widget _timeDivider(Timestamp time) {
    DateTime t = time.toDate();
    return Text(t.day.toString() +
        ' ' +
        months.elementAt(t.month - 1) +
        ', ' +
        t.year.toString());
  }

  bool sameDay(Timestamp present, Timestamp passt) {
    DateTime pastTime = passt.toDate();
    DateTime presentTime = present.toDate();
    if (pastTime.year < presentTime.year) return false;
    if (pastTime.month < presentTime.month) return false;
    return pastTime.day == presentTime.day;
  }

  _messageItem(DocumentSnapshot message, BuildContext context) {
    final bool isMe = message.data()['from'] == myId;
    Timestamp time = message.data()['time'];
    DateTime ttime = time.toDate();
    String minute = ttime.minute > 9
        ? ttime.minute.toString()
        : '0' + ttime.minute.toString();
    String ampm = ttime.hour >= 12 ? "PM" : "AM";
    int hour = ttime.hour >= 12 ? ttime.hour % 12 : ttime.hour;
    if (message.data()['isText'])
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
                hour.toString() + ":" + minute.toString() + " " + ampm,
                style: TextStyle(
                  color: Color(0xfff0f696),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                message.data()['message'].toString(),
                style: TextStyle(
                  color: isMe
                      ? Theme.of(context).colorScheme.onSecondary
                      : Theme.of(context).colorScheme.onPrimary,
                  fontSize: 16.0,
                ),
              )
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
    return FutureBuilder(
      future: dbHelper.getURLforImage(message.data()['photo'].toString()),
      builder: (context, snapshot) {
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
                  hour.toString() + ":" + minute.toString() + " " + ampm,
                  style: TextStyle(
                    color: Color(0xfff0f696),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                snapshot.hasData
                    ? InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewer(
                              snapshot.data.toString(),
                            ),
                          ),
                        ),
                        child: Hero(
                          tag: snapshot.data.toString(),
                          child: Container(
                            margin: EdgeInsets.all(4.0),
                            height: MediaQuery.of(context).size.width * 0.6,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(snapshot.data.toString()),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation(
                            Theme.of(context).colorScheme.primary,
                          ),
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
      },
    );
  }

  Widget _buildPopUpImagePicker(context) {
    PickedFile _imageFile;
    StorageUploadTask _taskUpload;
    bool uploadBool = false;
    double height = MediaQuery.of(context).size.height * 0.4;
    if (_taskUpload != null)
      _taskUpload.onComplete.then((value) async {
        StorageReference sRef = value.ref;
        String path = await sRef.getPath();
        await dbHelper.sendMessage(
            to: userId, from: myId, isText: false, path: path);
        Navigator.pop(context);
      });
    return StatefulBuilder(
      builder: (context, setState) => Align(
        alignment: Alignment.topCenter,
        child: Container(
          // padding: EdgeInsets.all(8.0),
          height: height,
          width: MediaQuery.of(context).size.width * .6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
          margin: EdgeInsets.only(bottom: 50, left: 12, right: 12, top: 50),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (!uploadBool) ...[
                  if (_imageFile == null)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .2,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MaterialButton(
                            textColor:
                                Theme.of(context).colorScheme.onSecondary,
                            onPressed: () async {
                              PickedFile image = await _picker.getImage(
                                  source: ImageSource.gallery);
                              setState(() {
                                _imageFile = image;
                                height =
                                    MediaQuery.of(context).size.height * 0.6;
                              });
                            },
                            color: Theme.of(context).colorScheme.secondary,
                            child: Text('Image from Gallery'),
                          ),
                        ),
                      ),
                    ),
                  if (_imageFile == null)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .2,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MaterialButton(
                            textColor:
                                Theme.of(context).colorScheme.onSecondary,
                            onPressed: () async {
                              PickedFile image = await _picker.getImage(
                                  source: ImageSource.camera);
                              setState(() {
                                _imageFile = image;
                                height =
                                    MediaQuery.of(context).size.height * 0.6;
                              });
                            },
                            color: Theme.of(context).colorScheme.secondary,
                            child: Text('Image from Camera'),
                          ),
                        ),
                      ),
                    ),
                  if (_imageFile != null)
                    Container(
                      padding: EdgeInsets.all(8.0),
                      margin: EdgeInsets.all(8.0),
                      height: MediaQuery.of(context).size.height * .4,
                      child: Image.file(
                        File(_imageFile.path),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  if (_imageFile != null)
                    SizedBox(
                      height: MediaQuery.of(context).size.width * .1,
                      child: Center(
                        child: MaterialButton(
                          color: Theme.of(context).colorScheme.secondary,
                          textColor: Theme.of(context).colorScheme.onSecondary,
                          onPressed: () => setState(() {
                            _imageFile = null;
                            height = MediaQuery.of(context).size.height * 0.4;
                          }),
                          child: Text('Clear Selection'),
                        ),
                      ),
                    ),
                  if (_imageFile != null)
                    SizedBox(
                      height: MediaQuery.of(context).size.width * .2,
                      child: Center(
                        child: Align(
                          alignment: Alignment.center,
                          child: FloatingActionButton(
                            onPressed: () async {
                              if (_imageFile != null) {
                                print("Image Sent!");
                                _taskUpload = await dbHelper.uploadImage(
                                    File(_imageFile.path), userId, myId);
                                setState(() => uploadBool = true);
                              }
                            },
                            child: Icon(
                              Icons.send,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ] else ...[
                  StreamBuilder<StorageTaskEvent>(
                    stream: _taskUpload.events,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        StorageTaskEvent taskEvent = snapshot.data;
                        StorageTaskSnapshot event = snapshot.data.snapshot;
                        if (taskEvent.type == StorageTaskEventType.success) {
                          StorageReference sRef = event.ref;
                          sRef.getPath().then((path) async {
                            await dbHelper.sendMessage(
                                to: userId,
                                from: myId,
                                isText: false,
                                path: path);
                            Navigator.pop(context);
                          });
                        }
                      }
                      return Container(
                        height: MediaQuery.of(context).size.height * .5,
                        width: MediaQuery.of(context).size.width * .5,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  showSnackPlz(BuildContext context, String username) {
    final SnackBar snackMe = SnackBar(
      content: new RichText(
        text: new TextSpan(
          style: new TextStyle(
            fontSize: 14.0,
          ),
          children: <TextSpan>[
            new TextSpan(
              text: 'User with email ',
            ),
            new TextSpan(
              text: username,
              style: new TextStyle(fontWeight: FontWeight.bold),
            ),
            new TextSpan(
              text: '@gmail.com not in the database!',
            ),
          ],
        ),
      ),
    );
    _scaffKey.currentState.showSnackBar(snackMe);
  }
}
