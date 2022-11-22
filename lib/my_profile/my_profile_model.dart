// ignore_for_file: await_only_futures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyProfileModel extends ChangeNotifier {
  late String uniquID;
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
    await firebase.collection('user').doc(uid).update({'uniquID': uniquID});
    notifyListeners();
  }

  Future chackCanUseId(String id) async {}
}
