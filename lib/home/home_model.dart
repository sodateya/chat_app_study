// ignore_for_file: missing_return

import 'package:chat_app_study/friend/friend_page.dart';
import 'package:chat_app_study/login/login.dart';
import 'package:chat_app_study/setting/setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeModel extends ChangeNotifier {
  List screens = [
    FriendPage(uid: FirebaseAuth.instance.currentUser!.uid),
    FriendPage(uid: FirebaseAuth.instance.currentUser!.uid),
    SettingPage(auth: FirebaseAuth.instance),
    FriendPage(uid: FirebaseAuth.instance.currentUser!.uid)
  ];

  int selectedIndex = 0;

  void onItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
