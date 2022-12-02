// ignore_for_file: missing_return

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../apply_list/apply_list.dart';
import '../friend_list/friend_page.dart';
import '../setting/setting.dart';
import '../talk_page/talk_page.dart';

class HomeModel extends ChangeNotifier {
  final screens = [
    FriendPage(uid: FirebaseAuth.instance.currentUser!.uid),
    TalkPage(roomID: FirebaseAuth.instance.currentUser!.uid),
    SettingPage(auth: FirebaseAuth.instance),
    ApplyListPage(uid: FirebaseAuth.instance.currentUser!.uid),
  ];

  int selectedIndex = 0;

  void onItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
