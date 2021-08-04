import 'package:cloud_firestore/cloud_firestore.dart';

class Call {
  final String id;
  final String caller;
  final String opener;
  final int whocaller;
  final String type;
  final Timestamp time;

  Call({this.whocaller, this.type, this.id, this.caller, this.opener, this.time});

  factory Call.producingDoc(DocumentSnapshot doc) {
    Map docData = doc.data();
    return Call(
        id: doc.id,
        caller: docData['caller'],
        opener: docData['opener'],
        whocaller : docData['whocaller'],
        type: docData['type'],
        time: docData['time']);
  }
}
