// ignore_for_file: missing_return

import 'package:chat_app_study/domain/friend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApplyListModel extends ChangeNotifier {
  List<Friend> userList = [];
  Map<String, dynamic> userInfo = {};

  final firestore = FirebaseFirestore.instance;

  Future fetchApplyList(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('friendApply')
        .where('applyState', isEqualTo: '申請中')
        .snapshots();
    doc.listen((snapshots) async {
      final userLists = snapshots.docs.map((doc) => Friend(doc)).toList();
      userList = userLists;
      notifyListeners();
    });
  }

  Future approve(Friend friend, String myID) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(myID)
        .collection('friendApply')
        .doc(friend.uid)
        .update({'approve': true, 'applyState': '承認'});

    await FirebaseFirestore.instance
        .collection('user')
        .doc(myID)
        .collection('friendList')
        .doc(friend.uid)
        .set({'uid': friend.uid, 'roomID': friend.roomId, 'applyState': '承認'});

    await FirebaseFirestore.instance
        .collection('user')
        .doc(friend.uid)
        .collection('friendList')
        .doc(myID)
        .update({'applyState': '承認'});
    notifyListeners();
  }

  Future notApprove(Friend friend, String myID) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(myID)
        .collection('friendApply')
        .doc(friend.uid)
        .update({'approve': false, 'applyState': '拒否'});

    await FirebaseFirestore.instance
        .collection('user')
        .doc(friend.uid)
        .collection('friendList')
        .doc(myID)
        .update({'applyState': '拒否'});

    notifyListeners();
  }

  Future getUserInfo(String uid) async {
    final doc = await firestore.collection('user').doc(uid).get();
    final userInfos = doc.data();
    userInfo = userInfos!;
    notifyListeners();
  }
}
