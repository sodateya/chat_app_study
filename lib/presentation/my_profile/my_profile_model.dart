// ignore_for_file: await_only_futures

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyProfileModel extends ChangeNotifier {
  late String uniquID;
  late String name;
  late bool isUsed;

  final firebase = FirebaseFirestore.instance;
  Map<String, dynamic> userInfo = {};

  Future getMyData(String uid) async {
    final doc = await firebase.collection('user').doc(uid).snapshots();
    doc.listen((snapshots) async {
      final userinfis = snapshots.data();
      userInfo = userinfis!;
    });
    notifyListeners();
  }

  Future updataUniquID(String uid) async {
    if (uniquID.isEmpty || uniquID == "") {
      throw ('IDを入力してください');
    }
    await chackCanUseId(uniquID);
    if (isUsed == true) {
      throw ('このIDは既に使用されています');
    }
    await firebase.collection('user').doc(uid).update({'uniquID': uniquID});
    notifyListeners();
  }

  Future updataName(String uid) async {
    await firebase.collection('user').doc(uid).update({'name': name});
    notifyListeners();
  }

  Future chackCanUseId(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .where('uniquID', isEqualTo: id)
        .get();
    final length = doc.docs.length;
    if (length == 0) {
      isUsed = false;
    } else {
      isUsed = true;
    }
    notifyListeners();
  }
}
