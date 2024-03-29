import 'dart:io';
import 'package:chat_app_study/domain/talk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'dart:math' as Math;

class TalkModel extends ChangeNotifier {
  List<Talk> talks = [];
  List<Talk> images = [];
  final firestore = FirebaseFirestore.instance;
  int documentLimit = 13;
  final firebase = FirebaseFirestore.instance;
  late DocumentSnapshot lastDocument;
  String message = '';
  File? imageFile;
  final picker = ImagePicker();
  bool isSending = false;
  String userIcon = '';

  void startSend() {
    isSending = true;
    notifyListeners();
  }

  void endSend() {
    isSending = false;
    notifyListeners();
  }

  void resetImage() {
    imageFile = null;
    notifyListeners();
  }

  Future getTalk(String roomID) async {
    firebase.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    print('get');
    final doc = await firebase
        .collection('rooms')
        .doc(roomID)
        .collection('talks')
        .orderBy('createdAt', descending: true)
        .snapshots();
    //     .get(const GetOptions(source: Source.cache));
    // final talk = doc.docs.map((e) => Talk(e)).toList();
    // talks = talk;
    notifyListeners();
    doc.listen((snapshots) async {
      final talk = snapshots.docs.map((doc) => Talk(doc)).toList();
      talks = talk;
      notifyListeners();
    });
  }

  Future getPicture(String roomID) async {
    final doc = firebase
        .collection('rooms')
        .doc(roomID)
        .collection('talks')
        .where('message', whereIn: [''])
        .orderBy('createdAt', descending: true)
        .snapshots();
    doc.listen((snapshots) async {
      final image = snapshots.docs.map((doc) => Talk(doc)).toList();
      images = image;
      print(image.length);
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
  }

  Future addMessage(String roomID, String uid) async {
    if (message == '') {
      throw ('メッセージを入力、または画像を選択してください');
    }
    final doc = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomID)
        .collection('talks')
        .doc();
    await doc.set({
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updateAt': FieldValue.serverTimestamp(),
      'message': message,
      'imgURL': '',
      'read': [uid]
    });
  }

  Future addImage(String roomID, String uid) async {
    print('スタート');
    final doc = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomID)
        .collection('talks')
        .doc();
    String? imgURL;
    if (imageFile != null) {
      final task = await FirebaseStorage.instance
          .ref('talk/${doc.id}')
          .putFile(imageFile!);
      imgURL = await task.ref.getDownloadURL();
    }
    await doc.set({
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updateAt': FieldValue.serverTimestamp(),
      'message': '',
      'imgURL': imgURL,
      'read': [uid]
    });
    print('フィニッシュ');
  }

  Future pickImage() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);
    imageFile = File(pickedFile!.path);
    return imageFile;
  }

  Future<String> getUserInfo(String uid) async {
    final doc = await firestore.collection('user').doc(uid).get();
    final icon = doc.data()!['photUrl'];
    notifyListeners();
    return icon;
  }

  Map<String, dynamic> focusInfo = {};
  Future getFocusInfo(
      uid, List<Map<String, Map<String, dynamic>>> userInfoList) async {
    print('pon');
    userInfoList.forEach((element) {
      if (element.keys.single == uid) {
        focusInfo = element.values.single;
      } else {}
    });
    return focusInfo;
  }
}
