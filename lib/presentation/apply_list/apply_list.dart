import 'package:chat_app_study/domain/friend.dart';
import 'package:chat_app_study/presentation/add_friend/add_friend.dart';
import 'package:chat_app_study/presentation/my_profile/my_prifile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'apply_list_model.dart';

// ignore: must_be_immutable
class ApplyListPage extends StatelessWidget {
  ApplyListPage({super.key, required this.uid});
  String uid;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    ScrollController scrollController = ScrollController();
    void getMore() async {
      print('ゲットモアー');
    }

    return ChangeNotifierProvider.value(
        value: ApplyListModel()..fetchApplyList(uid),
        child: Consumer<ApplyListModel>(builder: (context, model, child) {
          final friends = model.userList;
          return Scaffold(
            appBar: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Color(0xff8171D3),
                  Color(0xff9DD3E4)
                ] //グラデーションの設定
                        )),
              ),
              title: const Text('友達申請'),
              leading: IconButton(
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyProfilePage(uid: uid)));
                  },
                  icon: const Icon(Icons.account_circle)),
              actions: [
                IconButton(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddFriendPage(uid: uid)));
                    },
                    icon: const Icon(Icons.person_add_alt_1))
              ],
            ),
            body: friends.isEmpty
                ? const Center(
                    child: Text('現在申請されているユーザーはいません'),
                  )
                : SizedBox(
                    width: size.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              print('リフレッシュ');
                            },
                            child: SizedBox(
                              height: size.height * 0.8,
                              width: size.width * 0.97,
                              child: ListView.builder(
                                controller: scrollController
                                  ..addListener(getMore),
                                itemCount: friends.length,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return UserTile(friends[index], uid);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        }));
  }
}

class UserTile extends StatelessWidget {
  UserTile(this.friends, this.myID, {Key? key}) : super(key: key);
  Friend friends;
  String myID;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: ApplyListModel()..getUserInfo(friends.uid),
        child: Consumer<ApplyListModel>(builder: (context, model, child) {
          return model.userInfo.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  width: 50,
                  height: 50,
                  child: const CircularProgressIndicator(),
                )
              : ListTile(
                  title: Text(model.userInfo['name']),
                  leading: model.userInfo['photUrl'] != null
                      ? Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image:
                                      NetworkImage(model.userInfo['photUrl']))))
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
                              icon:
                                  const Icon(Icons.close, color: Colors.blue)),
                          IconButton(
                              onPressed: () async {
                                await model.approve(friends, myID);
                              },
                              icon:
                                  const Icon(Icons.check, color: Colors.green)),
                        ],
                      )),
                );
        }));
  }
}
