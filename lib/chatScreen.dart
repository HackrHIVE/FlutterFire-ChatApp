import 'package:cloud_firestore/cloud_firestore.dart';
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
  TextEditingController userController;
  final _scaffKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    userController = new TextEditingController();
    setState(() {
      dbHelper = new DatabaseHelper();
      offlineStorage = new OfflineStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffKey,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            // barrierDismissible: false,
            context: context,
            builder: (context) => _buildPopUpMessage(context),
          );
        },
        splashColor: Theme.of(context).colorScheme.onSecondary,
        child: Icon(
          Icons.add,
        ),
      ),
      body: FutureBuilder(
        future: offlineStorage.getUserInfo(),
        builder: (BuildContext context, AsyncSnapshot userDataSnapshot) {
          if (userDataSnapshot.hasData) {
            Map<dynamic, dynamic> user = userDataSnapshot.data;
            String myId = user['uid'];
            return StreamBuilder(
              stream: dbHelper.getChats(userId: myId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  QuerySnapshot qSnap = snapshot.data;
                  List<DocumentSnapshot> docs = qSnap.docs;
                  if (docs.length == 0)
                    return Center(
                      child: Text('No Chats yet!'),
                    );
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      List<dynamic> members = docs[index].data()['members'];
                      String userId;
                      userId = members.elementAt(0) == myId
                          ? members.elementAt(1)
                          : members.elementAt(0);
                      return FutureBuilder(
                        future: dbHelper.getUserByUsername(username: userId),
                        builder: (context, _snapshot) {
                          if (_snapshot.hasData) {
                            DocumentSnapshot docSnapUser = _snapshot.data;
                            Map<String, dynamic> _user = docSnapUser.data();
                            return Card(
                              margin: EdgeInsets.all(8.0),
                              elevation: 8.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: InkWell(
                                splashColor:
                                    Theme.of(context).colorScheme.primary,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailed(
                                      userData: _user,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  margin: EdgeInsets.all(10.0),
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Hero(
                                          tag: _user['photo'].toString(),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15,
                                            decoration: new BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: new DecorationImage(
                                                fit: BoxFit.cover,
                                                image: new NetworkImage(
                                                  _user['photo'].toString(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.43,
                                          child: Text(
                                            _user['name'].toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: _timeDivider(docs[index]
                                                .data()['lastActive']),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Card(
                            margin: EdgeInsets.all(8.0),
                            elevation: 8.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Container(
                              margin: EdgeInsets.all(10.0),
                              height: MediaQuery.of(context).size.height * 0.08,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
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
  }

  Widget _timeDivider(Timestamp time) {
    DateTime t = time.toDate();
    String minute =
        t.minute > 9 ? t.minute.toString() : '0' + t.minute.toString();
    String ampm = t.hour >= 12 ? "PM" : "AM";
    int hour = t.hour >= 12 ? t.hour % 12 : t.hour;
    DateTime press = DateTime.now();
    if (press.year == t.year && press.month == t.month && press.day == t.day)
      return Text(hour.toString() + ':' + minute + ' ' + ampm);
    return Text(t.day.toString() +
        '/' +
        (t.month + 1).toString() +
        '/' +
        t.year.toString());
  }

  Widget _buildPopUpMessage(context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.all(8.0),
        height: MediaQuery.of(context).size.width * .5,
        width: MediaQuery.of(context).size.width * .6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        margin: EdgeInsets.only(bottom: 50, left: 12, right: 12, top: 50),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.width * .1,
                child: Center(
                  child: new RichText(
                    text: new TextSpan(
                      style: new TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        new TextSpan(
                          text: 'username',
                          style: new TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold),
                        ),
                        new TextSpan(
                          text: '@gmail.com',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * .2,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      child: TextField(
                        autofocus: true,
                        controller: userController,
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
                          hintText: "Type in only Username",
                          hintStyle: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * .1,
                child: Center(
                  child: Align(
                    alignment: Alignment.center,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        'Let\'s chat with your friend.',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary),
                      ),
                      onPressed: () async {
                        if (userController.text.isNotEmpty) {
                          String username = userController.text.toString();
                          userController.clear();
                          QuerySnapshot doc = await dbHelper.getUserByEmail(
                            email: username + '@gmail.com',
                          );
                          if (doc.docs.length != 0) {
                            DocumentSnapshot user = doc.docs[0];
                            Map<String, dynamic> userData = user.data();
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailed(
                                  userData: userData,
                                ),
                              ),
                            );
                            print(user.data()['name'].toString());
                          } else {
                            showSnackPlz(context, username);
                            Navigator.pop(context);
                          }
                        } else {
                          showSnackPlzWithMessage(context, 'Empty Username');
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
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

  showSnackPlzWithMessage(BuildContext context, String message) {
    final SnackBar snackMe = SnackBar(
      content: new Text(message),
    );
    _scaffKey.currentState.showSnackBar(snackMe);
  }
}
