import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/talk.dart';

class TalkModel extends ChangeNotifier {
  List<Talk> talks = [];
  final firestore = FirebaseFirestore.instance;
  int documentLimit = 13;
  final firebase = FirebaseFirestore.instance;
  late DocumentSnapshot lastDocument;
  String message = '';
  String imgURL = '';
  Future getTalk(String roomID) async {
    print('get');
    final doc = firebase
        .collection('rooms')
        .doc(roomID)
        .collection('talks')
        .orderBy('createdAt', descending: true)
        .snapshots();
    doc.listen((snapshots) async {
      final talk = snapshots.docs.map((doc) => Talk(doc)).toList();
      talks = talk;
      notifyListeners();
    });
  }

  Future read(String roomID, String uid, String id) async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomID)
        .collection('talks')
        .doc(id)
        .update({
      'read': FieldValue.arrayUnion([uid])
    });
    print(id);
  }

  Future addMessage(String roomID, String uid) async {
    if (message == '') {
      throw ('メッセージを入力してください');
    }
    await firebase.collection('rooms').doc(roomID).collection('talks').add({
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updateAt': FieldValue.serverTimestamp(),
      'message': message,
      'imgURL': imgURL,
      'read': [uid]
    });
  }

  File? imageFile;
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    imageFile = File(pickedFile!.path);
    print(imageFile);
    notifyListeners();
  }
}
