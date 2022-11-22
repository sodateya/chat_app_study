import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  Friend(DocumentSnapshot doc) {
    uid = doc['uid'];
    name = doc['name'];
    photoURL = doc['userImage'];
    roomId = doc['roomID'];
  }
  late String uid;
  late String name;
  late String photoURL;
  late String roomId;
}
