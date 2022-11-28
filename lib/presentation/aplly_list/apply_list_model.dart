// ignore_for_file: missing_return

import 'dart:math';

import 'package:chat_app_study/domain/friend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        .where('approve', isEqualTo: false)
        .snapshots();
    doc.listen((snapshots) async {
      final userLists = snapshots.docs.map((doc) => Friend(doc)).toList();
      userList = userLists;
      notifyListeners();
    });
  }
}
