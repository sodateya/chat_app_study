import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  Friend(DocumentSnapshot doc) {
    uid = doc['uid'];
    roomId = doc['roomID'];
    applyState = doc['applyState'];
  }
  late String uid;
  late String roomId;
  late String applyState;
}
