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

  getUserByEmail(String email) async {
    return await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .getDocuments();
  }

  //TODO:Add all functionalities of Firestore here required for app.
  getChats(String uid) {
    return _db
        .collection('chats')
        .where('members', arrayContains: uid)
        .orderBy('lastActive', descending: true)
        .snapshots();
  }

  generateChatId(String username1, String username2) {
    return username1.toString().compareTo(username2.toString()) < 0
        ? username1.toString() + '-' + username2.toString()
        : username2.toString() + '-' + username1.toString();
  }

  Future<bool> checkChatExistsOrNot(String username1, String username2) async {
    String chatId = generateChatId(username1, username2);
    DocumentSnapshot doc = await _db.collection('chats').document(chatId).get();
    return doc.exists;
  }

  sendMessage(String to, String from, String msg) async {
    bool existsOrNot = await checkChatExistsOrNot(to, from);
    Firestore tempDb = Firestore.instance;
    String chatId = generateChatId(from, to);
    if (!existsOrNot) {
      List<String> members = [to, from];
      Timestamp now = Timestamp.now();
      await tempDb
          .collection('chats')
          .document(generateChatId(to, from))
          .collection('messages')
          .add(
        {'from': from, 'message': msg, 'time': now, 'isText': true},
      );
      await tempDb
          .collection('chats')
          .document(chatId)
          .setData({'lastActive': now, 'members': members});
    } else {
      Timestamp now = Timestamp.now();
      await tempDb
          .collection('chats')
          .document(chatId)
          .collection('messages')
          .add(
        {'from': from, 'message': msg, 'time': now, 'isText': true},
      );
      await tempDb
          .collection('chats')
          .document(chatId)
          .updateData({'lastActive': now});
    }
  }
}
