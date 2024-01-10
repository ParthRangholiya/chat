import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethode {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint("\nError signing in : $e");
      SnackBar(
        content: Text("Soomthing Went wrong (Check Internet Connection)"),
        backgroundColor: Colors.black87,
      );
    }
    return null;
  }
}

button() {
  final AuthMethode authMethode = AuthMethode();
  authMethode.signInWithGoogle().then((user) {});
}
