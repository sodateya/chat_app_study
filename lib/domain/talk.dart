import 'package:cloud_firestore/cloud_firestore.dart';

class Talk {
  Talk(DocumentSnapshot doc) {
    uid = doc['uid'];
    final Timestamp createdTimestamp = doc['createdAt'] ?? Timestamp.now();
    createdAt = createdTimestamp.toDate();
    final Timestamp updateTimestamp = doc['updateAt'] ?? Timestamp.now();
    updateAt = updateTimestamp.toDate();
    message = doc['message'];
    imgURL = doc['imgURL'];
    read = doc['read'];
  }
  late List read;
  late String uid;
  late DateTime createdAt;
  late DateTime updateAt;
  late String message;
  late String imgURL;
}
