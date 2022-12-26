import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'authentication_error.dart';
import 'dart:math' as math;

class LoginModel extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  String infoText = ""; // ログインに関する情報を表示
  final auth_error = Authentication_error(); // エラーメッセージを日本語化するためのクラス
  bool isreadAgree = false;
  bool ischeckedAgree = false;
  late UserCredential result;
  late User user;
  late String name;
  bool agreeToTerms = false;
  late bool isUsedQR;
  String randomStr = "";

  void isAgreeToTerms(bool? value) {
    agreeToTerms = value ?? false;
    notifyListeners();
  }

  Future chackCanUseQRpass(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .where('RQpass', isEqualTo: id)
        .get();
    final length = doc.docs.length;
    if (length == 0) {
      isUsedQR = false;
      print(isUsedQR);
    } else {
      isUsedQR = true;
      print(isUsedQR);
    }
    print(randomStr);
    notifyListeners();
  }

  Future randomString(int length) async {
    randomStr = "";
    var random = math.Random();
    for (var i = 0; i < length; i++) {
      int alphaNum = 65 + random.nextInt(26);
      int isLower = random.nextBool() ? 32 : 0;
      randomStr += String.fromCharCode(alphaNum + isLower);
    }
    return await randomStr;
  }

  Future readAgree() async {
    isreadAgree = true;
    print(isreadAgree);
    notifyListeners();
  }

  Future checkedAgree() async {
    ischeckedAgree = true;
    notifyListeners();
  }

  void loginErrorMessage(dynamic e) {
    print(e);
    infoText = auth_error.login_error_msg(e.code);
    notifyListeners();
  }

  Future createUserDatabase(User user) async {
    if (name.isEmpty || name == "") {
      throw ('名前を入力してください');
    }
    final token = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance.collection('user').doc(user.uid).set({
      'uid': user.uid,
      'photUrl': user.photoURL ?? '',
      'name': user.displayName ?? name,
      'RQpass': randomStr,
      'uniquID': '',
      'pushToken': token
    });
  }

  Future createUserDatabaseForGoogle(User user) async {
    final token = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance.collection('user').doc(user.uid).set({
      'uid': user.uid,
      'photUrl': user.photoURL,
      'name': user.displayName,
      'RQpass': randomStr,
      'uniquID': '',
      'pushToken': token
    });
  }

  // Future lunchTermsOfService() async {
  //   await launch('https://hz-360fa.web.app/');
  //   notifyListeners();
  // }
}
