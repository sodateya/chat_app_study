// ignore_for_file: missing_return

import 'package:chat_app_study/presentation/get_uid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../friend_list/friend_page.dart';
import '../room_list/room_list.dart';
import '../setting/setting.dart';

class HomeModel extends ChangeNotifier {
  final screens = [
    FriendListPage(uid: FirebaseAuth.instance.currentUser!.uid),
    RoomListPage(uid: FirebaseAuth.instance.currentUser!.uid),
    SettingPage(auth: FirebaseAuth.instance),
    GetUidPage(),
  ];

  int selectedIndex = 0;

  void onItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
