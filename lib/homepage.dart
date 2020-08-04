import 'package:firebase_chatapp/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'addScreen.dart';
import 'auth.dart';
import 'chatScreen.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           if (_profile != null)
  //             CircleAvatar(
  //               radius: 20,
  //               backgroundImage: NetworkImage(
  //                 _profile['photo'].toString(),
  //               ),
  //             ),
  //           if (_profile != null)
  //             Text(
  //               _profile['name'].toString(),
  //               style: TextStyle(
  //                 fontSize: 20,
  //               ),
  //             ),
  //           if (_profile != null)
  //             Text(
  //               _profile['email'].toString(),
  //               style: TextStyle(
  //                 fontSize: 14,
  //               ),
  //             ),
  //           MaterialButton(
  //             onPressed: () => authService.signOut(),
  //             child: Text('Signout'),
  //             textColor: Colors.black,
  //             color: Colors.red,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [ChatScreen(), AddScreen(), ProfileScreen()];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home),
        title: ("Chats"),
        activeColor: CupertinoColors.activeBlue,
        inactiveColor: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.settings),
        title: ("Add Friends"),
        activeColor: CupertinoColors.activeBlue,
        inactiveColor: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.profile_circled),
        title: ("Profile"),
        activeColor: CupertinoColors.activeBlue,
        inactiveColor: CupertinoColors.systemGrey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      popAllScreensOnTapOfSelectedTab: true,
      navBarStyle: NavBarStyle.style3,
    );
  }
}
