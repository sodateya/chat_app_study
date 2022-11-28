import 'dart:io';

import 'package:flutter/material.dart';

// ignore_for_file: missing_return
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../domain/talk.dart';

class TalkModel extends ChangeNotifier {
  List<Talk> talks = [];
  final firestore = FirebaseFirestore.instance;
  int documentLimit = 13;
  late DocumentSnapshot lastDocument;
  late String comment;
//   final picker = ImagePicker();
//  late File imageFile;
  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future getTalk(String roomID) async {
    final querySnapshot = firestore
        .collection('rooms')
        .doc(roomID)
        .collection('talk')
        .orderBy('createdAt', descending: true)
        .limit(documentLimit)
        .snapshots();
    try {
      querySnapshot.listen((snapshots) async {
        lastDocument = snapshots.docs.last;
        final talks = snapshots.docs.map((doc) => Talk(doc)).toList();
        this.talks = talks;
        notifyListeners();
      });
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future getMoreTalk(String roomID) async {
    final docs = firestore
        .collection('rooms')
        .doc(roomID)
        .collection('talk')
        .orderBy('createdAt', descending: true)
        .limit(documentLimit)
        .startAfterDocument(lastDocument)
        .limit(10)
        .snapshots();
    docs.listen((snapshots) async {
      try {
        lastDocument = snapshots.docs.last;
        final talks = snapshots.docs.map((doc) => Talk(doc)).toList();
        this.talks.addAll(talks);
      } catch (e) {
        print('終了');
      }
      notifyListeners();
    });
  }

  Future deleteAdd(Talk talk, String roomID) async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomID)
        .collection('talk')
        .doc(talk.documentID)
        .delete();
    notifyListeners();
  }

  Future addThreadToFirebase(String uid, String roomID) async {
    final db = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomID)
        .collection('talk')
        .doc();
    if (comment.isEmpty == null) {
      throw ('メッセージを入力してください');
    }
    // String imgURL;
    // if (imageFile != null) {
    //   final task = await FirebaseStorage.instance
    //       .ref('talk/${db.id}')
    //       .putFile(imageFile);
    //   imgURL = await task.ref.getDownloadURL();
    // }

    await db.set({
      'comment': comment,
      'createdAt': Timestamp.now(),
      'uid': uid,
      'url': '',
      'imgURL': '' ?? '',
    });
  }

  // Future pickImage() async {
  //   final pickedFile = await picker.getImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     imageFile = File(pickedFile.path);
  //   }
  //   notifyListeners();
  // }

  // Future resetImage() {
  //   imageFile = null;
  //   notifyListeners();
  // }

  // String handleName;

  // Future getName() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();

  //   if (pref.getString('handleName') == null) {
  //     await pref.setString('handleName', '名無しさん');
  //     handleName = pref.getString('handleName');
  //   } else {
  //     handleName = pref.getString('handleName');
  //   }
  //   notifyListeners();
  // }
}
