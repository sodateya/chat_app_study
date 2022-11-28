// ignore_for_file: missing_return

import 'dart:math';

import 'package:chat_app_study/domain/friend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendModel extends ChangeNotifier {
  List<Friend> userList = [];
  Map<String, dynamic> userInfo = {};

  final firestore = FirebaseFirestore.instance;
  Future getUserList(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('friendList')
        .get();
    final userLists = doc.docs.map((doc) => Friend(doc)).toList();
    userList = userLists;
    notifyListeners();
  }

  Future fetchUserList(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('friendList')
        .snapshots();
    doc.listen((snapshots) async {
      final userLists = snapshots.docs.map((doc) => Friend(doc)).toList();
      userList = userLists;
      notifyListeners();
    });
  }

  Future addUserList() async {
    final room = await FirebaseFirestore.instance.collection('rooms').add({
      'createdAt': Timestamp.now(),
    });
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('friendList')
        .doc(user.uid)
        .set({
      'uid': user.uid,
      'name': user.displayName,
      'userImage': user.photoURL,
      'roomID': room.id,
    });
  }

  Future getUserInfo(String uid) async {
    final doc = await firestore.collection('user').doc(uid).get();
    final userInfos = doc.data();
    userInfo = userInfos!;
    notifyListeners();
  }
}