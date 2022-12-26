import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddFriendModel extends ChangeNotifier {
  String uniquID = '';
  late Map<String, dynamic> firendData;
  late bool isAlreadyId;
  late bool isMyFriend;

  Map<String, dynamic> userInfo = {};

  Future getFriendDada(String id, String uid) async {
    if (id == '') {
      throw ('IDを入力してください');
    }
    await chackAlreadyFriendId(id);
    if (isAlreadyId == false) {
      throw ('該当するユーザーはいません');
    }
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .where('uniquID', isEqualTo: id)
        .get();
    firendData = await doc.docs.first.data();
    await chackIsMyFriend(firendData['uid'], uid);
    if (isMyFriend == true) {
      throw ('既に友達のユーザーです');
    }
    notifyListeners();
  }

  Future getFriendDadaForQR(Map<String, dynamic> result, String uid) async {
    await chackAlreadyFriendQR(result['RQpass']);
    if (isAlreadyId == false) {
      throw ('該当するユーザーはいません');
    }
    await chackIsMyFriend(result['uid'], uid);
    if (isMyFriend == true) {
      throw ('既に友達のユーザーです');
    }
    notifyListeners();
  }

  Future chackIsMyFriend(String friendUid, String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('friendList')
        .where('uid', isEqualTo: friendUid)
        .get();
    final length = doc.docs.length;
    if (length == 0) {
      isMyFriend = false;
    } else {
      isMyFriend = true;
    }
    notifyListeners();
  }

  Future chackAlreadyFriendQR(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .where('RQpass', isEqualTo: id)
        .get();
    final length = doc.docs.length;
    if (length == 0) {
      isAlreadyId = false;
    } else {
      isAlreadyId = true;
    }
    notifyListeners();
  }

  Future chackAlreadyFriendId(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .where('uniquID', isEqualTo: id)
        .get();
    final length = doc.docs.length;
    if (length == 0) {
      isAlreadyId = false;
    } else {
      isAlreadyId = true;
    }
    notifyListeners();
  }

  Future addFiriend(Map<String, dynamic> friendData, String uid) async {
    final room = await FirebaseFirestore.instance.collection('rooms').add({
      'createdAt': Timestamp.now(),
      'updateAt': Timestamp.now(),
      'lastComment': '',
      'member': [uid, friendData['uid']]
    });
    await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('friendList')
        .doc(friendData['uid'])
        .set(
            {'uid': friendData['uid'], 'roomID': room.id, 'applyState': '申請中'});
    await FirebaseFirestore.instance
        .collection('user')
        .doc(friendData['uid'])
        .collection('friendApply')
        .doc(uid)
        .set({'uid': uid, 'roomID': room.id, 'applyState': '申請中'});
  }
}
