import 'package:cloud_firestore/cloud_firestore.dart';

class Talk {
  Talk(DocumentSnapshot doc) {
    uid = doc['uid'];
    final Timestamp timestamp = doc['createdAt'];
    createdAt = timestamp.toDate();
    documentID = doc.id;
    comment = doc['comment'];
    url = doc['url'];
    imgURL = doc['imgURL'];
  }
  late String uid;
  late DateTime createdAt;
  late String documentID;
  late String comment;
  late String url;
  late String imgURL;
}
