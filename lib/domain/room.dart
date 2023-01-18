import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  Room(DocumentSnapshot doc) {
    final Timestamp createdTimestamp = doc['createdAt'] ?? Timestamp.now();
    createdAt = createdTimestamp.toDate();
    final Timestamp updateTimestamp = doc['updateAt'] ?? Timestamp.now();
    updateAt = updateTimestamp.toDate();
    lastComment = doc['lastComment'];
    member = doc['member'];
    id = doc.id;
  }
  late List member;
  late DateTime createdAt;
  late DateTime updateAt;
  late String lastComment;
  late String id;
}
