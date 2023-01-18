import 'package:chat_app_study/domain/talk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/room.dart';

class RoomListModel extends ChangeNotifier {
  final firestore = FirebaseFirestore.instance;
  Map<String, dynamic> userInfo = {};
  List<Map<String, Map<String, dynamic>>> userInfoList = [];
  List<Room> roomList = [];

  Future getRoomList(String uid) async {
    final doc = await firestore
        .collection('rooms')
        .where('member', arrayContains: uid)
        .get();

    final roomLists = doc.docs.map((doc) => Room(doc)).toList();
    roomList = roomLists;
    notifyListeners();
  }

  List nameList = [];
  List tokenList = [];
  List uidList = [];
  Future getUserInfo(List uidList, String uid) async {
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    if (uidList.length == 2) {
      uidList.remove(uid);
      final doc = await firestore.collection('user').doc(uidList.first).get();
      final userInfos = doc.data();
      userInfo = userInfos!;
      notifyListeners();
    } else {
      for (var i = 0; i < uidList.length; i++) {
        try {
          final doc = await firestore
              .collection('user')
              .doc(uidList[i])
              .get(const GetOptions(source: Source.cache));
          userInfoList.add({doc.data()!['uid']: doc.data()!});
          nameList.add(doc.data()!['name']);
          tokenList.add(doc.data()!['pushToken']);
        } catch (e) {
          final doc = await firestore.collection('user').doc(uidList[i]).get();
          userInfoList.add({doc.data()!['uid']: doc.data()!});
          nameList.add(doc.data()!['name']);
          tokenList.add(doc.data()!['pushToken']);
        }
      }
      String names = nameList.join(',');
      String tokens = tokenList.toString();
      String uids = uidList.toString();
      userInfo = {
        'uid': uids,
        'uniquID': '',
        'photUrl': 'https://cdn-icons-png.flaticon.com/512/1246/1246366.png',
        'name': names,
        'QRpass': '',
        'pushToken': tokens,
      };
      notifyListeners();
    }
  }
}
