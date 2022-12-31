import 'package:cloud_firestore/cloud_firestore.dart';

class UserDB {
  UserDB(DocumentSnapshot doc) {
    qQpass = doc['QRpass'];
    name = doc['name'];
    photUrl = doc['photUrl'];
    pushToken = doc['pushToken'];
    uid = doc['uid'];
    uniquID = doc['uniquID'];
  }
  late String qQpass;
  late String name;
  late String photUrl;
  late String pushToken;
  late String uid;
  late String uniquID;
}
