import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chatapp/Helper/OfflineStore.dart';

class DatabaseHelper {
  Firestore _db;
  OfflineStorage offlineStorage;

  DatabaseHelper() {
    _db = Firestore.instance;
    offlineStorage = new OfflineStorage();
  }

  getUserByUsername(String username) async {
    return await _db.collection('users').document(username).get();
  }

  //TODO:Add all functionalities of Firestore here required for app.
  getChats() async {
    Map<String, String> userInfo = await offlineStorage.getUserInfo();
    return await _db
        .collection('chats')
        .where('members', arrayContains: userInfo['uid'].toString())
        .orderBy('lastActive', descending: true)
        .getDocuments();
  }
}
