import 'package:flutter/material.dart';

import 'Helper/OfflineStore.dart';
import 'auth.dart';

class ProfileScreen extends StatefulWidget {
  Map<String, dynamic> userData;
  ProfileScreen({this.userData});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  OfflineStorage offlineStorage;
  @override
  void initState() {
    super.initState();
    setState(() {
      offlineStorage = new OfflineStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (widget.userData == null)
          ? FutureBuilder(
              future: offlineStorage.getUserInfo(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Map<String, String> user = snapshot.data;
                  return Center(
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.8,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Card(
                        margin: EdgeInsets.all(8.0),
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  user['photo'],
                                ),
                              ),
                              Text(
                                user['name'],
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                user['email'],
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              MaterialButton(
                                onPressed: () => authService.signOut(),
                                child: Text('Signout'),
                                textColor:
                                    Theme.of(context).colorScheme.onSecondary,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else
                  return Center(
                    child: Text('Loading Profile...'),
                  );
              },
            )
          : Center(
              child: Container(
                height: MediaQuery.of(context).size.width * 0.8,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Card(
                  margin: EdgeInsets.all(8.0),
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            widget.userData['photo'].toString(),
                          ),
                        ),
                        Text(
                          widget.userData['name'].toString(),
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          widget.userData['email'].toString(),
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        MaterialButton(
                          onPressed: () => authService.signOut(),
                          child: Text('Signout'),
                          textColor: Theme.of(context).colorScheme.onSecondary,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        FloatingActionButton(
                          child: Icon(
                            Icons.arrow_back,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
