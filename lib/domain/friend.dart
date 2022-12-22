import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  Friend(DocumentSnapshot doc) {
    uid = doc['uid']; //友達のUID
    roomID = doc['roomID']; //トークルームのID
    applyState = doc['applyState']; //申請中かどうか？
  }
  late String uid;
  late String roomID;
  late String applyState;
}
