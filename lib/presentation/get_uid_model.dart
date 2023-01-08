import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GetUidModel extends ChangeNotifier {
  String uid = 'なし';

  Future<dynamic> setUserw() async {
    final userAth = FirebaseAuth.instance.currentUser!;
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;
    final users = FirebaseFirestore.instance.collection("users");
    final userCollection =
        await FirebaseFirestore.instance.collection("users").doc().get();
    final docs = userCollection.data()!['roomId'];
    if (docs.isEmpty) {
      await users.doc().set({
        "joined_user_ids": [uid],
      });
      print('追加しました');
    } else {
      print('既に登録済みのユーザーでした');
    }
  }
}
