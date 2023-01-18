// ignore: unused_import
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_study/domain/talk.dart';
import 'package:chat_app_study/presentation/my_profile/my_prifile.dart';
import 'package:chat_app_study/presentation/room_list/room_list_model.dart';
import 'package:chat_app_study/presentation/talk_page/talk_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/room.dart';
import '../add_friend/add_friend.dart';

class RoomListPage extends StatelessWidget {
  RoomListPage({
    super.key,
    required this.uid,
  });
  String uid;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    ScrollController scrollController = ScrollController();
    return ChangeNotifierProvider.value(
        value: RoomListModel()..getRoomList(uid),
        child: Consumer<RoomListModel>(builder: (context, model, child) {
          final rooms = model.roomList;
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
              title: const Text('トークリスト'),
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
                      showBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25.0)),
                          ),
                          builder: ((context) {
                            return AddFriendListPage(
                              uid: uid,
                              size: size,
                            );
                          }));
                    },
                    icon: const Icon(Icons.person_add_alt_1))
              ],
            ),
            body: rooms.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                        child: Text('現在友達はいません'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          //   model.getUserList(uid);
                        },
                        child: const Text('再読み込み'),
                      )
                    ],
                  )
                : SizedBox(
                    child: Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {},
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: rooms.length,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: (UserTile(rooms[index], uid, size)),
                                );
                              },
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
  UserTile(this.rooms, this.uid, this.size, {Key? key}) : super(key: key);
  Room rooms;
  String uid;
  Size size;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: RoomListModel()..getUserInfo(rooms.member, uid),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Consumer<RoomListModel>(builder: (context, model, child) {
            return model.userInfo.isEmpty
                ? Container(
                    alignment: Alignment.center,
                    width: 25,
                    height: 25,
                    child: const CircularProgressIndicator(),
                  )
                : ListTile(
                    title: Text(
                      model.userInfo['name'],
                      overflow: TextOverflow.ellipsis,
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
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TalkPage(
                                    roomID: rooms.id,
                                    uid: uid,
                                    size: size,
                                    userInfo: model.userInfo,
                                    userInfoList: model.userInfoList,
                                  )));
                    },
                  );
          }),
        ));
  }
}
