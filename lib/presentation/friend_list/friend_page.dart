import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_study/domain/friend.dart';
import 'package:chat_app_study/domain/user.dart';
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
    ScrollController scrollController2 = ScrollController();

    return ChangeNotifierProvider.value(
        value: FriendModel()
          ..fetchUserList(uid)
          ..fetchAllUserList(), //FriendMdelを使って..getCacheUserListでUserの情報をとる
        child: Consumer<FriendModel>(builder: (context, model, child) {
          void getMore() async {
            print('getMore');
          }

          final size = MediaQuery.of(context).size;

          final friends = model.userList;
          final allUser = model.allUserList;
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
                    child: Column(
                      children: [
                        RefreshIndicator(
                          onRefresh: () async {
                            print('po');
                          },
                          child: SizedBox(
                            height: size.height * 0.12,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: scrollController2,
                              itemCount: allUser.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconTile(allUser[index], uid, size),
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              await model.fetchUserList(uid);
                            },
                            child: SizedBox(
                              height: size.height * 0.654,
                              width: size.width * 0.97,
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: friends.length,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return index == 0
                                      ? Container(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  top: BorderSide(
                                                      color: Colors.grey,
                                                      width: 0),
                                                  bottom: BorderSide(
                                                      color: Colors.grey,
                                                      width: 0))),
                                          child: UserTile(
                                              friends[index], uid, size))
                                      : Container(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey,
                                                      width: 0))),
                                          child: UserTile(
                                              friends[index], uid, size));
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
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Consumer<FriendModel>(builder: (context, model, child) {
            return model.userInfo.isEmpty
                ? Container(
                    alignment: Alignment.center,
                    width: 25,
                    height: 25,
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
                    leading: model.userInfo['photUrl'] != ''
                        ? Container(
                            height: 55,
                            width: 55,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: model.userInfo['photUrl'],
                            ),
                          )
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
                                        roomID: friends.roomID,
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
          }),
        ));
  }
}

class IconTile extends StatelessWidget {
  IconTile(this.allUser, this.uid, this.size, {Key? key}) : super(key: key);
  UserDB allUser;
  String uid;
  Size size;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: FriendModel()..getForAllUserInfo(allUser.uid),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                print(allUser.name);
              },
              child: allUser.photUrl != ''
                  ? Container(
                      height: 55,
                      width: 55,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: allUser.photUrl,
                      ),
                    )
                  : Container(
                      height: 55,
                      width: 55,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage('images/user.png')))),
            ),
            SizedBox(
              width: 55,
              child: Center(
                child: Text(
                  allUser.name,
                  maxLines: 1,
                ),
              ),
            )
          ],
        ));
  }
}
