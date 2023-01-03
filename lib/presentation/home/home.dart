// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:chat_app_study/presentation/add_friend/add_friend_model.dart';
import 'package:chat_app_study/presentation/add_friend/qr_scan_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import '../add_friend/add_friend.dart';
import 'home_model.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamSubscription? _sub;
  String? catchLink;
  String? parameter;

  @override
  void initState() {
    initUniLinks();
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String? getQueryParameter(String? link) {
    if (link == null) return null;
    final uri = Uri.parse(link);
    //flutterUniversity://user/?name=matsumaruのmatsumaru部分を取得
    String? name = uri.queryParameters['code'];
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: HomeModel(),
      child: Consumer<HomeModel>(builder: (context, model, child) {
        return Scaffold(
            body: IndexedStack(
              index: model.selectedIndex,
              children: model.screens,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: model.selectedIndex,
              onTap: model.onItemTapped,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle), label: '友達リスト'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble), label: 'トーク'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: '設定'),
                BottomNavigationBarItem(icon: Icon(Icons.check), label: '友達申請'),
              ],
              type: BottomNavigationBarType.fixed,
            ));
      }),
    );
  }

  Map<String, dynamic>? firendData;
  late bool isAlreadyId;
  late bool isMyFriend;

  Future<void> initUniLinks() async {
    _sub = linkStream.listen((String? link) async {
      //さっき設定したスキームをキャッチしてここが走る。
      catchLink = link;
      parameter = getQueryParameter(link);
      setState(() {});
      print(parameter);
      try {
        await check(parameter!, FirebaseAuth.instance.currentUser!.uid);
        addFriendUseQR(firendData!, AddFriendModel(),
            FirebaseAuth.instance.currentUser!.uid, context);
      } catch (e) {
        await showDialog(
            context: context,
            builder: ((context) {
              return AlertDialog(
                title: Text(e.toString()),
                actions: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                            child: const Text('閉じる')),
                      ],
                    ),
                  )
                ],
              );
            }));
      }
    }, onError: (err) {
      print(err);
    });
  }

  Future addFriendUseQR(Map<String, dynamic> data, AddFriendModel model,
      String uid, BuildContext context) async {
    try {
      await model.getFriendDadaForQR(data, uid);
      await showDialog(
          context: context,
          builder: ((context) {
            return AlertDialog(
              title: Column(
                children: [
                  data['photUrl'] != null
                      ? Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(data['photUrl']))))
                      : Container(
                          height: 55,
                          width: 55,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: AssetImage('images/user.png')))),
                  Text(data['name']),
                ],
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                      onPressed: () async {
                        await model.addFiriend(data, uid);
                        await showDialog(
                            context: context,
                            builder: ((context) {
                              return const AlertDialog(
                                title: Text('追加しました'),
                              );
                            }));
                        Navigator.of(context).pop();
                      },
                      child: const Text('追加する')),
                )
              ],
            );
          }));
    } catch (e) {
      await showDialog(
          context: context,
          builder: ((context) {
            return AlertDialog(
              title: Text(e.toString()),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: const Text('閉じる')),
                  ],
                ),
              ],
            );
          }));
    }
  }

  Future getFriendDadaForQR(Map<String, dynamic> result, String uid) async {
    await chackAlreadyFriendQR(result['QRpass']);
    if (isAlreadyId == false) {
      throw ('該当するユーザーが見つかりませんでした');
    }
    await chackIsMyFriend(result['uid'], uid);
    if (isMyFriend == true) {
      throw ('既に友達のユーザーです');
    }
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
  }

  Future check(String pass, String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('user')
          .where('QRpass', isEqualTo: pass)
          .get();
      final length = doc.docs.length;
      if (length == 0) {
        throw ('該当するユーザーが見つかりません');
      } else {
        firendData = doc.docs.first.data();
      }
    } catch (e) {
      throw ('該当するユーザーが見つかりませんでした');
    }
  }
}
