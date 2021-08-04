import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsup/Models/Person.dart';
import 'package:whatsup/Screens/Homes.dart';
import 'package:whatsup/Screens/Login.dart';
class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String userid;

  handleAuth() {
    return StreamBuilder(
        stream: AuthService().chasing,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasData) {
            Person user = snapshot.data;
            userid = user.id;
           return Mainpage(id: user.id);
          } else
            return Login();
        });
  }

  Person creatinguser(User kullanici) {
    return kullanici == null ? null : Person.producingFirebase(kullanici);
  }

  Stream<Person> get chasing {
    return _auth.authStateChanges().map(creatinguser);
  }

  signOut() {
    FirebaseAuth.instance.signOut();
  }

  signIn(AuthCredential authCreds, var number) async {
    UserCredential credential =
        await FirebaseAuth.instance.signInWithCredential(authCreds);
    creatinguser(credential.user);
  }

  Future<Person> signInWithOTP(smsCode, verId, number) async {
    AuthCredential authCreds =
        PhoneAuthProvider.credential(verificationId: verId, smsCode: smsCode);
    UserCredential credential =
        await FirebaseAuth.instance.signInWithCredential(authCreds);
    return creatinguser(credential.user);
  }
}
