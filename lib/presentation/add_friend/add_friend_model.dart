import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import '../../domain/friend.dart';

class AddFriendModel extends ChangeNotifier {
  String uniquID = '';
  Map<String, dynamic>? firendData;
  late bool isAlreadyId;
  late bool isMyFriend;
  String? erroeMsg;
  bool isInControllerText = false;
  String data = '';
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);
    data = pickedFile!.path;
  }

  Future decode() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);
    final file = pickedFile!.path;
    String data = await QrCodeToolsPlugin.decodeFrom(file);
    this.data = data;
    print(this.data);
    notifyListeners();
  }

  void resetUserData() async {
    firendData = await null;
    notifyListeners();
  }

  void resetError() {
    erroeMsg = null;
    notifyListeners();
  }

  void catchError(String e) {
    erroeMsg = e;
    notifyListeners();
  }

  void inText() {
    isInControllerText = true;
    notifyListeners();
  }

  void notInText() {
    isInControllerText = false;
    notifyListeners();
  }

  Future getFriendDada(String id, String uid) async {
    if (id == '') {
      throw ('IDを入力してください');
    }
    await chackAlreadyFriendId(id);
    if (isAlreadyId == false) {
      throw ('該当するユーザーはいません');
    }
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .where('uniquID', isEqualTo: id)
        .get();
    firendData = await doc.docs.first.data();
    await chackIsMyFriend(firendData!['uid'], uid);
    if (isMyFriend == true) {
      throw ('既に友達のユーザーです');
    }
    notifyListeners();
  }

  Future getFriendDadaForQR(Map<String, dynamic> result, String uid) async {
    await chackAlreadyFriendQR(result['QRpass']);
    if (isAlreadyId == false) {
      throw ('該当するユーザーはいません');
    }
    await chackIsMyFriend(result['uid'], uid);
    if (isMyFriend == true) {
      throw ('既に友達のユーザーです');
    }
    notifyListeners();
  }

  Future chackIsMyFriend(String friendUid, String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('friendList')
        .where('uid', isEqualTo: friendUid)
        .get();
    final length = doc.docs.length;
    if (length == 0) {
      isMyFriend = false;
    } else {
      isMyFriend = true;
    }
    notifyListeners();
  }

  Future chackAlreadyFriendQR(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .where('QRpass', isEqualTo: id)
        .get();
    final length = doc.docs.length;
    if (length == 0) {
      isAlreadyId = false;
    } else {
      isAlreadyId = true;
    }
    notifyListeners();
  }

  Future chackAlreadyFriendId(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .where('uniquID', isEqualTo: id)
        .get();
    final length = doc.docs.length;
    if (length == 0) {
      isAlreadyId = false;
    } else {
      isAlreadyId = true;
    }
    notifyListeners();
  }

  Future addFiriend(Map<String, dynamic> friendData, String uid) async {
    final room = await FirebaseFirestore.instance.collection('rooms').add({
      'createdAt': Timestamp.now(),
      'updateAt': Timestamp.now(),
      'lastComment': '',
      'member': [uid, friendData['uid']]
    });
    await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('friendList')
        .doc(friendData['uid'])
        .set(
            {'uid': friendData['uid'], 'roomID': room.id, 'applyState': '申請中'});
    await FirebaseFirestore.instance
        .collection('user')
        .doc(friendData['uid'])
        .collection('friendApply')
        .doc(uid)
        .set({'uid': uid, 'roomID': room.id, 'applyState': '申請中'});
  }

  List<Friend> userList = [];
  Map<String, dynamic> userInfo = {};

  final firestore = FirebaseFirestore.instance;

  Future fetchApplyList(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('friendApply')
        .where('applyState', isEqualTo: '申請中')
        .snapshots();
    doc.listen((snapshots) async {
      final userLists = snapshots.docs.map((doc) => Friend(doc)).toList();
      userList = userLists;
      notifyListeners();
    });
  }

  Future approve(Friend friend, String myID) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(myID)
        .collection('friendApply')
        .doc(friend.uid)
        .update({'approve': true, 'applyState': '承認'});

    await FirebaseFirestore.instance
        .collection('user')
        .doc(myID)
        .collection('friendList')
        .doc(friend.uid)
        .set({'uid': friend.uid, 'roomID': friend.roomID, 'applyState': '承認'});

    await FirebaseFirestore.instance
        .collection('user')
        .doc(friend.uid)
        .collection('friendList')
        .doc(myID)
        .update({'applyState': '承認'});
    notifyListeners();
  }

  Future notApprove(Friend friend, String myID) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(myID)
        .collection('friendApply')
        .doc(friend.uid)
        .update({'approve': false, 'applyState': '拒否'});

    await FirebaseFirestore.instance
        .collection('user')
        .doc(friend.uid)
        .collection('friendList')
        .doc(myID)
        .update({'applyState': '拒否'});

    notifyListeners();
  }

  Future getUserInfo(String uid) async {
    final doc = await firestore.collection('user').doc(uid).get();
    final userInfos = doc.data();
    userInfo = userInfos!;
    notifyListeners();
  }
}
