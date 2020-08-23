import 'package:shared_preferences/shared_preferences.dart';

class OfflineStorage {
  //TODO:Add all functionalities of Offline Shared Preference here required for app.

  SharedPreferences pref;

  saveUserInfo(String photo, String name, String email, String uid) async {
    pref = await SharedPreferences.getInstance();
    print('saving userInfo');
    await pref.setString("photo", photo);
    await pref.setString("name", name);
    await pref.setString("email", email);
    await pref.setString("uid", uid);
  }

  getUserInfo() async {
    pref = await SharedPreferences.getInstance();
    print('getting userInfo');
    String photo = pref.getString("photo");
    String name = pref.getString("name");
    String email = pref.getString("email");
    String uid = pref.getString("uid");
    return {'photo': photo, 'name': name, 'email': email, 'uid': uid};
  }
}