// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:chat_app_study/presentation/add_friend/qr_scan_page.dart';
import 'package:chat_app_study/presentation/add_friend/seach_by_id_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/friend.dart';
import 'add_friend_model.dart';

class AddFriendListPage extends StatelessWidget {
  AddFriendListPage({super.key, required this.uid, required this.size});
  String uid;
  Size size;
  ScrollController scrollController = ScrollController();
  void getMore() async {
    print('ゲットモアー');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: AddFriendModel()..fetchApplyList(uid),
        child: Consumer<AddFriendModel>(builder: (context, model, child) {
          final friends = model.userList;
          return SizedBox(
            height: size.height * 0.8,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                      ),
                      const Text(
                        '友達追加',
                        style: TextStyle(fontSize: 20),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ],
                  ),
                ),
                SearchButtoms(size, model, uid),
                friends.isEmpty
                    ? const Center(
                        child: Text('現在申請されているユーザーはいません'),
                      )
                    : Flexible(
                        child: SizedBox(
                          width: size.width,
                          child: Column(
                            children: [
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () async {
                                    print('リフレッシュ');
                                  },
                                  child: ListView.builder(
                                    controller: scrollController,
                                    itemCount: friends.length,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return UserTile(friends[index], uid);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
              ],
            ),
          );
        }));
  }
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
    print(e);
    final snackBar = SnackBar(
      backgroundColor: const Color(0xffD0104C),
      content: Text(e.toString()),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class SearchButtoms extends StatelessWidget {
  SearchButtoms(this.size, this.model, this.uid, {Key? key}) : super(key: key);
  Size size;
  String uid;
  AddFriendModel model;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125,
      child: Row(
        children: [
          Flexible(
              child: Container(
                  width: size.width / 3,
                  height: 125,
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                      color: Colors.grey,
                    )),
                  ),
                  child: GestureDetector(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.switch_account_outlined,
                              color: Color.fromARGB(255, 85, 85, 85),
                              size: 50,
                            ),
                          ),
                          Text(
                            '招待',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 85, 85, 85),
                            ),
                          )
                        ],
                      ),
                      onTap: () async {
                        await model.decode();
                      }))),
          Flexible(
              child: Container(
            width: size.width / 3,
            height: 125,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                ),
                right: BorderSide(
                  color: Colors.grey,
                ),
                left: BorderSide(
                  color: Colors.grey,
                ),
              ),
            ),
            child: GestureDetector(
              onTap: () async {
                print('pin');
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            QRScanPage(size: size, uid: uid)));
                if (result != null) {
                  await addFriendUseQR(result, model, uid, context);
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.qr_code,
                      size: 50,
                      color: Color.fromARGB(255, 85, 85, 85),
                    ),
                  ),
                  Text(
                    'QRコード',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(255, 85, 85, 85),
                    ),
                  )
                ],
              ),
            ),
          )),
          Flexible(
              child: Container(
            width: size.width / 3,
            height: 125,
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                color: Colors.grey,
              )),
            ),
            child: GestureDetector(
              onTap: () async {
                showDialog(
                    context: context,
                    builder: ((constext) {
                      return AlertDialog(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0))),
                          content: SearchByIdPage(size, uid));
                    }));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.search,
                      size: 50,
                      color: Color.fromARGB(255, 85, 85, 85),
                    ),
                  ),
                  Text(
                    '検索',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(255, 85, 85, 85),
                    ),
                  )
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  UserTile(this.friends, this.myID, {Key? key}) : super(key: key);
  Friend friends;
  String myID;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: AddFriendModel()..getUserInfo(friends.uid),
        child: Consumer<AddFriendModel>(builder: (context, model, child) {
          return model.userInfo.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  width: 50,
                  height: 50,
                  child: const CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(model.userInfo['name']),
                    leading: model.userInfo['photUrl'] != null
                        ? Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(
                                        model.userInfo['photUrl']))))
                        : Container(
                            height: 55,
                            width: 55,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage('images/user.png')))),
                    trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () async {
                                  await model.notApprove(friends, myID);
                                },
                                icon: const Icon(Icons.close,
                                    color: Colors.blue)),
                            IconButton(
                                onPressed: () async {
                                  await model.approve(friends, myID);
                                },
                                icon: const Icon(Icons.check,
                                    color: Colors.green)),
                          ],
                        )),
                  ),
                );
        }));
  }
}
