import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_twitch/models/user.dart' as model;
import 'package:flutter_twitch/provider/user_provider.dart';
import 'package:flutter_twitch/utils/utils.dart';
import 'package:provider/provider.dart';

class AuthMethods {
  final userRef = FirebaseFirestore.instance.collection("users");
  final auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getCurrentUser(String? uid) async {
    if (uid != null) {
      final snap = await userRef.doc(uid).get();
      return snap.data();
    }
    return null;
  }

  Future<bool> signUpUser({
    required String email,
    required String username,
    required String password,
    required BuildContext context,
  }) async {
    bool res = false;
    try {
      UserCredential cred = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (cred.user != null) {
        model.User user = model.User(
          username: username.trim(),
          email: email.trim(),
          uid: cred.user!.uid,
        );

        await userRef.doc(cred.user!.uid).set(user.toMap());
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        res = true;
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
    return res;
  }

  Future<bool> logInUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    bool res = false;
    try {
      UserCredential cred = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (cred.user != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(
            model.User.fromMap(await getCurrentUser(cred.user!.uid) ?? {}));
        res = true;
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
    return res;
  }
}
