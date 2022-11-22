import 'package:chat_app_study/my_profile/my_prifile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'friend_model.dart';

// ignore: must_be_immutable
class FriendPage extends StatelessWidget {
  FriendPage({super.key, required this.uid});
  String uid;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    ScrollController scrollController = ScrollController();
    void getMore() async {
      print('ゲットモアー');
    }

    return ChangeNotifierProvider.value(
        value: FriendModel()..getUserList(uid),
        child: Consumer<FriendModel>(builder: (context, model, child) {
          final friends = model.userList;
          return Scaffold(
            appBar: AppBar(
              title: const Text('友達リスト'),
              actions: [
                IconButton(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyProfilePage(uid: uid)));
                    },
                    icon: const Icon(Icons.account_circle))
              ],
            ),
            body: friends.isEmpty
                ? const Center(
                    child: Text('現在友達はいません'),
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
                                  return UserTile(friends[index].uid);
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
  UserTile(this.uid, {Key? key}) : super(key: key);
  String uid;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: FriendModel()..getUserInfo(uid),
        child: Consumer<FriendModel>(builder: (context, model, child) {
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
                );
        }));
  }
}
