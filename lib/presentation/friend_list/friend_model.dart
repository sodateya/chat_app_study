// ignore_for_file: missing_return

import 'dart:math';

import 'package:chat_app_study/domain/friend.dart';
import 'package:chat_app_study/domain/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

List<Friend> userList = [];

class FriendModel extends ChangeNotifier {
  List<Friend> userList = [];
  List<UserDB> allUserList = [];
  Map<String, dynamic> userInfo = {};
  Map<String, dynamic> allUserInfo = {};
  final firestore = FirebaseFirestore.instance;
  List<Map<String, Map<String, dynamic>>> userInfoList = [];

  Future getUserList(String uid) async {
    final doc = await firestore
        .collection('user')
        .doc(uid)
        .collection('friendList')
        .get();
    final userLists = doc.docs.map((doc) => Friend(doc)).toList();
    userList = userLists;
    notifyListeners();
  }

  Future fetchUserList(String uid) async {
    //firestoreからデータ取得
    final doc = await firestore
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

  Future fetchAllUserList() async {
    //firestoreからデータ取得
    final doc = await firestore.collection('user').snapshots();
    doc.listen((snapshots) async {
      final userLists = snapshots.docs.map((doc) => UserDB(doc)).toList();
      allUserList = userLists;
      notifyListeners();
    });
  }

  Future getAllUserList() async {
    //firestoreからデータ取得
    final doc = await firestore.collection('user').get();
    final userLists = doc.docs.map((doc) => UserDB(doc)).toList();
    allUserList = userLists;
    notifyListeners();
  }

  Future getCacheUserList(String uid) async {
    //uid=自分のUID  キャッシュからデータを取得（26行目）
    var cache = FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('friendList');
    cache.get(const GetOptions(source: Source.cache)).then((doc) {
      if (doc.docs == null) {
        throw "data is null !";
      } //
      final userLists = doc.docs.map((doc) => Friend(doc)).toList();
      userList = userLists;
      notifyListeners();
    }).catchError((error) {
      //キャッシュにデータがなかったら fetchUserList(uid);
      print("no cache:  $error");
      fetchUserList(uid);
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

  Future getForAllUserInfo(String uid) async {
    final doc = await firestore.collection('user').doc(uid).get();
    final userInfos = doc.data();
    allUserInfo = userInfos!;
    notifyListeners();
  }
}
