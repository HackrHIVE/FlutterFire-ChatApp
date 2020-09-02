import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Helper/OfflineStore.dart';
import 'Helper/auth.dart';

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
    setState(() => offlineStorage = new OfflineStorage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.userData == null
          ? Theme.of(context).colorScheme.secondary
          : Theme.of(context).colorScheme.primary,
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
                                radius: 40,
                                backgroundImage: NetworkImage(
                                  user['photo'],
                                ),
                              ),
                              Text(
                                user['name'],
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                user['email'],
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
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
                        Hero(
                          tag: widget.userData['photo'].toString(),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              widget.userData['photo'].toString(),
                            ),
                          ),
                        ),
                        Text(
                          widget.userData['name'].toString(),
                          style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.userData['email'].toString(),
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
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
