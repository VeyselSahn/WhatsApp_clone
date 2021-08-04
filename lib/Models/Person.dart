import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Person{
  
  final String id;
  final String username;
  final String number;
  final String photo;
  final String about;

  Person( {this.username,this.about, this.id, this.number, this.photo});

  factory Person.producingFirebase(User kullanici) {
    return Person(
      id: kullanici.uid,
      username: kullanici.displayName,
      photo: kullanici.photoURL,
      number: kullanici.phoneNumber,
      about: "Hey.I'm using WhatsUp."
    );
  }

  factory Person.producingDoc(DocumentSnapshot doc) {
    Map data = doc.data();
    return Person(
      id: doc.id,
      username: data['username'],
      number: data['phone'],
      photo: data['photo'],
      about: data['about']

    );
  }

}