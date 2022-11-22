import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User(DocumentSnapshot doc) {
    uid = doc['uid'];
    name = doc['name'];
    photoURL = doc['userImage'];
    roomId = doc['roomID'];
    accountId = doc['accountId'];
  }
  late String uid;
  late String name;
  late String photoURL;
  late String roomId;
  late String accountId;
}
