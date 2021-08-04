import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  String id;
  Reference _storage = FirebaseStorage.instance.ref();

  Future<String> imagemessage(File image) async {
    id = Uuid().v4();
    UploadTask task = _storage.child("Imagemessage/message$id.jpg").putFile(image);
    TaskSnapshot snapshot = await task;
    String url = await snapshot.ref.getDownloadURL();

    return url;
  }
    Future<String> instantphotos(File image) async {
    id = Uuid().v4();
    UploadTask task = _storage.child("Instantphotos/instant$id.jpg").putFile(image);
    TaskSnapshot snapshot = await task;
    String url = await snapshot.ref.getDownloadURL();

    return url;
  }

  Future<String> profilephotos(File image) async {
    id = Uuid().v4();
    UploadTask task = _storage.child("Profilephotos/profile$id.jpg").putFile(image);
    TaskSnapshot snapshot = await task;
    String url = await snapshot.ref.getDownloadURL();

    return url;
  }

  void deleteimagemessage(String url){
    RegExp search = RegExp(r"message.+\.jpg");
    var connect = search.firstMatch(url);
    String nameable = connect[0];

    if(nameable != null){_storage.child(
        "Imagemessage/$nameable").delete();
    }
  }
}