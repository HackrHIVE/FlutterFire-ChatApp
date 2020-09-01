import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chatapp/Helper/OfflineStore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DatabaseHelper {
  Firestore _db;
  OfflineStorage offlineStorage;
  FirebaseStorage _firebaseStorage =
      FirebaseStorage(storageBucket: 'gs://fir-realtime-65cf4.appspot.com');
  StorageUploadTask _uploadTask;

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

  sendMessage(
      {@required String to,
      @required String from,
      @required bool isText,
      String msg,
      String path}) async {
    bool existsOrNot = await checkChatExistsOrNot(to, from);
    Firestore tempDb = Firestore.instance;
    String chatId = generateChatId(from, to);
    Timestamp now = Timestamp.now();
    if (!existsOrNot) {
      List<String> members = [to, from];
      isText
          ? await tempDb
              .collection('chats')
              .document(chatId)
              .collection('messages')
              .add(
              {'from': from, 'message': msg, 'time': now, 'isText': true},
            )
          : await tempDb
              .collection('chats')
              .document(chatId)
              .collection('messages')
              .add(
              {'from': from, 'photo': path, 'time': now, 'isText': false},
            );
      await tempDb
          .collection('chats')
          .document(chatId)
          .setData({'lastActive': now, 'members': members});
    } else {
      isText
          ? await tempDb
              .collection('chats')
              .document(chatId)
              .collection('messages')
              .add(
              {'from': from, 'message': msg, 'time': now, 'isText': true},
            )
          : await tempDb
              .collection('chats')
              .document(chatId)
              .collection('messages')
              .add(
              {'from': from, 'photo': path, 'time': now, 'isText': false},
            );
      await tempDb
          .collection('chats')
          .document(chatId)
          .updateData({'lastActive': now});
    }
  }

  uploadImage(File _image, String to, String from) {
    String filePath =
        'chatImages/${generateChatId(to, from)}/${DateTime.now()}.png';
    _uploadTask = _firebaseStorage.ref().child(filePath).putFile(_image);
    return _uploadTask;
  }

  getURLforImage(String imagePath) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference sRef = await storage
        .getReferenceFromUrl('gs://fir-realtime-65cf4.appspot.com');
    StorageReference pathReference = sRef.child(imagePath);
    return await pathReference.getDownloadURL();
  }
}
