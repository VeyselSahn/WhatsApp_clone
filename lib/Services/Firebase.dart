import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsup/Instant/models/story_model.dart';
import 'package:whatsup/Models/Person.dart';

class Firebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final DateTime time = DateTime.now();

  Future<void> kullaniciOlustur(
      {id,
      phone,
      username ,
      photo ,
      about }) async {
    await _firestore.collection("Users").doc(id).set({
      "username": username,
      "phone": phone,
      "photo": photo,
      "about": about,
      "time": time,
    });
  }

  Future<Person> getUser(id) async {
    DocumentSnapshot document =
        await _firestore.collection("Users").doc(id).get();
    if (document.exists) {
      Person user = Person.producingDoc(document);
      return user;
    } else
      return null;
  }

  Future<List<Person>> getAllUsers() async {
    QuerySnapshot doc = await _firestore.collection("Users").get();
    List<Person> list = doc.docs.map((e) => Person.producingDoc(e)).toList();
    return list;
  }

  void updateUser(
      {String id, String username, String about, String photo = ""}) {
    _firestore
        .collection("Users")
        .doc(id)
        .update({"username": username, "about": about, "photo": photo});
  }

  Stream<QuerySnapshot> getChatFriends(String id) {
    return _firestore
        .collection("Chatfriends")
        .doc(id)
        .collection("List")
        .snapshots();
  }

  Future<void> deleteChatFriends(String id, receiver) async {
    await _firestore
        .collection("Chatfriends")
        .doc(id)
        .collection("List")
        .doc(receiver)
        .delete();
  }

  Future<void> deleteCalls(String id) async {
    QuerySnapshot snap = await _firestore
        .collection("Calls")
        .doc(id)
        .collection("List").get();
    snap.docs.forEach((element) {
      if(element.exists) {
        element.reference.delete();
      }
    });
  }

  addChatFriend({String ownerId, String receiverId}) {
    _firestore
        .collection("Chatfriends")
        .doc(ownerId)
        .collection("List")
        .doc(receiverId)
        .set({});

    _firestore
        .collection("Chatfriends")
        .doc(receiverId)
        .collection("List")
        .doc(ownerId)
        .set({});
  }

  Future<List<Person>> searchUser(String search) async {
    QuerySnapshot snap = await _firestore
        .collection("Users")
        .where("username", isLessThanOrEqualTo: search)
        .get();
    List<Person> list = snap.docs.map((e) => Person.producingDoc(e)).toList();
    return list;
  }

  Stream<QuerySnapshot> getMessages(String ownerId) {
    return _firestore
        .collection("Messages")
        .doc(ownerId)
        .collection("List")
        .orderBy("time", descending: false)
        .snapshots();
  }

  addMessage({
    String ownerId,
    String receiverId,
    String text,
    String url,
  }) {
    _firestore.collection("Messages").doc(ownerId).collection("List").add({
      "text": text,
      "ownerId": ownerId,
      "receiverId": receiverId,
      "url": url,
      "time": time
    });

    _firestore.collection("Messages").doc(receiverId).collection("List").add({
      "text": text,
      "ownerId": ownerId,
      "receiverId": receiverId,
      "time": time
    });
  }

  Stream<QuerySnapshot> getLastMessages(String ownerId) {
    return _firestore
        .collection("Messages")
        .doc(ownerId)
        .collection("List")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future<void> deleteMessages(String owner, String receiver) async {
    QuerySnapshot snapshot = await _firestore
        .collection("Messages")
        .doc(owner)
        .collection("List")
        .where("receiverId", isEqualTo: receiver)
        .get();
    snapshot.docs.forEach((sendingmessage) {
      if (sendingmessage.exists) {
        sendingmessage.reference.delete();
      }
    });
    QuerySnapshot snap = await _firestore
        .collection("Messages")
        .doc(owner)
        .collection("List")
        .where("ownerId", isEqualTo: receiver)
        .get();
    snap.docs.forEach((takingmessage) {
      if (takingmessage.exists) {
        takingmessage.reference.delete();
      }
    });
    await deleteChatFriends(owner, receiver);
  }

  Future<void> createStory(
      {String owner, String url, String media, String caption}) async {
    await _firestore.collection("Stories").doc(owner).collection("List").add({
      "owner": owner,
      "url": url,
      "media": media,
      "time": time,
      "caption": caption
    });
  }

  addStoryOwner({String id}) {
    _firestore
        .collection("Storyowners")
        .doc("owners")
        .collection("List")
        .doc(id)
        .set({});
  }

  Future<List<Person>> getStoryOwners() async {
    QuerySnapshot doc = await _firestore
        .collection('Storyowners')
        .doc('owners')
        .collection('List')
        .get();
    List<Person> list = doc.docs.map((e) => Person.producingDoc(e)).toList();
    return list;
  }

  Future<List<Story>> getStories(String id) async {
    QuerySnapshot doc =
        await _firestore.collection('Stories').doc(id).collection('List').get();
    List<Story> list = doc.docs.map((e) => Story.producingDoc(e)).toList();
    return list;
  }

  Stream<QuerySnapshot> getCalls(String id) {
    return _firestore
        .collection("Calls")
        .doc(id)
        .collection("List")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future<void> addCall({String caller, String opener, String type}) async {
    await _firestore
        .collection("Calls")
        .doc(caller)
        .collection("List")
        .add({"caller": caller, "opener": opener, "type": type, "time": time});

    await _firestore
        .collection("Calls")
        .doc(opener)
        .collection("List")
        .add({"caller": caller, "opener": opener, "type": type, "time": time});
  }
}
