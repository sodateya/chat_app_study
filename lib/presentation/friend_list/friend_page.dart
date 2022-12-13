import 'package:chat_app_study/domain/friend.dart';
import 'package:chat_app_study/presentation/talk_page/talk_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../add_friend/add_friend.dart';
import '../my_profile/my_prifile.dart';
import 'friend_model.dart';

// ignore: must_be_immutable
class FriendPage extends StatelessWidget {
  FriendPage({super.key, required this.uid});
  String uid;

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    return ChangeNotifierProvider.value(
        value: FriendModel()
          ..getUserList(uid), //FriendMdelを使って..getCacheUserListでUserの情報をとる
        child: Consumer<FriendModel>(builder: (context, model, child) {
          void getMore() async {
            print('getMore');
          }

          final size = MediaQuery.of(context).size;

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
              title: const Text('友達リスト'),
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
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                        child: Text('現在友達はいません'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          model.getCacheUserList(uid);
                        },
                        child: const Text('再読み込み'),
                      )
                    ],
                  )
                : SizedBox(
                    width: size.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              await model.fetchUserList(uid);
                            },
                            child: SizedBox(
                              height: size.height * 0.8,
                              width: size.width * 0.97,
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: friends.length,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return UserTile(friends[index], uid, size);
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
  UserTile(this.friends, this.uid, this.size, {Key? key}) : super(key: key);
  Friend friends;
  String uid;
  Size size;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: FriendModel()..getUserInfo(friends.uid),
        child: Consumer<FriendModel>(builder: (context, model, child) {
          return model.userInfo.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  width: 50,
                  height: 50,
                  child: const CircularProgressIndicator(),
                )
              : ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(model.userInfo['name']),
                      Text(
                        friends.applyState,
                        style: TextStyle(color: () {
                          switch (friends.applyState) {
                            case '申請中':
                              return Colors.green;
                            case '承認':
                              return Colors.blue;
                            case '拒否':
                              return Colors.red;
                            default:
                          }
                        }()),
                      ),
                    ],
                  ),
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
                  onTap: () async {
                    switch (friends.applyState) {
                      case '申請中':
                        showDialog(
                            context: context,
                            builder: ((context) {
                              return const AlertDialog(
                                title: Text('申請中です'),
                              );
                            }));
                        break;
                      case '承認':
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TalkPage(
                                      roomID: friends.roomId,
                                      uid: uid,
                                      size: size,
                                      userInfo: model.userInfo,
                                    )));
                        print('トーク画面へ');
                        break;
                      case '拒否':
                        showDialog(
                            context: context,
                            builder: ((context) {
                              return const AlertDialog(
                                title: Text('申請を拒否 されました'),
                              );
                            }));
                        break;
                      default:
                    }
                  },
                );
        }));
  }
}
