import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

import 'OfflineStore.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  OfflineStorage offlineStorage = new OfflineStorage();

  Stream<FirebaseUser> user;
  Stream<Map<String, dynamic>> profile;
  PublishSubject loading = PublishSubject();

  AuthService() {
    user = _auth.onAuthStateChanged;
    profile = user.switchMap(
      (FirebaseUser u) {
        if (u != null)
          return _db
              .collection('users')
              .document(u.uid)
              .snapshots()
              .map((snap) => snap.data);
        print("FirebaseUser is null!");
        return Stream.empty();
      },
    );
  }

  Future<FirebaseUser> googleSignIn() async {
    loading.add(true);
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    updateUserData(user);
    await offlineStorage.saveUserInfo(
        user.photoUrl, user.displayName, user.email, user.uid);
    return user;
  }

  void updateUserData(FirebaseUser user) async {
    DocumentReference ref = _db.collection('users').document(user.uid);
    profile = _auth.onAuthStateChanged.switchMap(
      (FirebaseUser u) {
        if (u != null)
          return _db
              .collection('users')
              .document(u.uid)
              .snapshots()
              .map((snap) => snap.data);
        return Stream.empty();
      },
    );
    return ref.setData({
      'uid': user.uid,
      'email': user.email,
      'photo': user.photoUrl,
      'name': user.displayName
    }, merge: true);
  }

  void signOut() => _auth.signOut();
}

final AuthService authService = AuthService();
