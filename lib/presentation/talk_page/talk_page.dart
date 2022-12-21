// ignore_for_file: must_be_immutable, missing_return, use_build_context_synchronously

import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_study/domain/custom_cache_manager.dart';
import 'package:chat_app_study/domain/talk.dart';
import 'package:chat_app_study/presentation/talk_page/picture_list_page.dart';
import 'package:chat_app_study/presentation/talk_page/picture_page.dart';
import 'package:chat_app_study/presentation/talk_page/talk_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

//File imageFile;

class TalkPage extends StatelessWidget {
  TalkPage(
      {super.key,
      required this.roomID,
      required this.uid,
      required this.size,
      required this.userInfo});
  late String roomID;
  late String uid;
  late Size size;
  late Map<String, dynamic> userInfo;

  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: TalkModel()..getTalk(roomID),
        child: Builder(builder: (ctx) {
          return GestureDetector(
            onTap: () => FocusScope.of(ctx).unfocus(),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: const Text('トーク'),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                    Color(0xff8171D3),
                    Color(0xff9DD3E4)
                  ] //グラデーションの設定
                          )),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PictureListPage(
                                size: size,
                                roomID: roomID,
                              ),
                              fullscreenDialog: true,
                            ));
                      },
                      child: const Text('写真一覧'),
                    ),
                  ),
                ],
              ),
              body: Consumer<TalkModel>(builder: (ctx, model, child) {
                final talks = model.talks;
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 70),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ListView.builder(
                          reverse: true,
                          shrinkWrap: true,
                          // controller: scrollController
                          //   ..addListener(getMore),
                          itemCount: talks.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (ctx, index) {
                            return talks[index].uid == uid
                                ? myTalk(size, talks[index])
                                : IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        index == talks.length - 1 ||
                                                talks[index].uid !=
                                                    talks[index + 1].uid
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      height: size.width * 0.1,
                                                      width: size.width * 0.1,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              fit: BoxFit.fill,
                                                              image: NetworkImage(
                                                                  userInfo[
                                                                      'photUrl'])))),
                                                ],
                                              )
                                            : Container(
                                                height: size.width * 0.1,
                                                width: size.width * 0.1,
                                              ),
                                        otherTalk(
                                            size, talks[index], roomID, uid),
                                      ],
                                    ),
                                  );
                          },
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      margin: const EdgeInsets.all(15.0),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.photo_camera,
                                      color: Colors.blueAccent),
                                  onPressed: () async {
                                    await model
                                        .pickImage()
                                        .then((value) => value != null
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PicturePage(
                                                    ontap: () async {
                                                      await model.addImage(
                                                          roomID, uid);
                                                    },
                                                    imageFile: model.imageFile,
                                                    size: size,
                                                  ),
                                                  fullscreenDialog: true,
                                                ))
                                            : print(value));
                                  },
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(35.0),
                                  // ignore: prefer_const_literals_to_create_immutables
                                  boxShadow: [
                                    const BoxShadow(
                                        offset: Offset(0, 3),
                                        blurRadius: 5,
                                        color: Colors.grey)
                                  ],
                                ),
                                child: Row(
                                  // ignore: prefer_const_literals_to_create_immutables
                                  children: [
                                    Expanded(
                                        child: Column(
                                      children: [
                                        Scrollbar(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: TextField(
                                              maxLines: 10,
                                              minLines: 1,
                                              onChanged: (value) {
                                                model.message = value;
                                              },
                                              controller: commentController,
                                              decoration: const InputDecoration(
                                                  hintText: "メッセージを入力...",
                                                  hintStyle: TextStyle(
                                                      color: Colors.blueAccent),
                                                  border: InputBorder.none),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                model.isSending == false
                                    ? IconButton(
                                        icon: const Icon(Icons.send,
                                            color: Colors.blueAccent),
                                        onPressed: () async {
                                          try {
                                            model.startSend();
                                            await model.addMessage(roomID, uid);
                                          } catch (e) {
                                            print(e);
                                            final snackBar = SnackBar(
                                              backgroundColor: Colors.redAccent,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              duration: const Duration(
                                                  milliseconds: 1000),
                                              margin: const EdgeInsets.only(
                                                bottom: 40,
                                              ),
                                              content: Text(
                                                e.toString(),
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          } finally {
                                            model.endSend();
                                          }
                                          commentController.clear();
                                          model.message = '';
                                          model.imageFile = null;
                                        },
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          );
        }));
  }
}

Widget otherTalk(Size size, Talk talk, String roomID, String uid) {
  return ChangeNotifierProvider.value(
      value: TalkModel(),
      child: Consumer<TalkModel>(builder: (context, model, child) {
        if (talk.read.contains(uid)) {
        } else {
          model.read(roomID, uid, talk.id);
          print('既読');
        }
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: size.width * 0.6,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: talk.message != ''
                        ? Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xffE96B6D),
                                Color(0xffEF995F)
                              ] //グラデーションの設定
                                  ),
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xff2d3441),
                            ),
                            child: Text(
                              talk.message,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Color(0xffFCFAF2),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ))
                        : GestureDetector(
                            onTap: () async {
                              await launch(talk.imgURL);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                    maxWidth: 150.0, maxHeight: 200.0),
                                child: CachedNetworkImage(
                                  imageUrl: talk.imgURL,
                                  cacheManager: customCacheManager,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                  ),
                                ),
                              ),
                            )),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        child: Text(DateFormat('HH:mm').format(talk.createdAt),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            textAlign: TextAlign.left),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }));
}

Widget myTalk(Size size, Talk talk) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: size.width * 0.6,
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      child: talk.read.length <= 1
                          ? const Text('')
                          : const Text('既読',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                              textAlign: TextAlign.left),
                    ),
                    SizedBox(
                      child: Text(DateFormat('HH:mm').format(talk.createdAt),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.left),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 8,
                ),
                Flexible(
                    child: talk.message != ''
                        ? Container(
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xffB08BD3),
                                Color(0xff6A75BD)
                              ] //グラデーションの設定
                                  ),
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xff2d3441),
                            ),
                            child: Text(
                              talk.message,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Color(0xffFCFAF2),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () async {
                              await launch(talk.imgURL);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                    maxWidth: 150.0, maxHeight: 200.0),
                                child: CachedNetworkImage(
                                  imageUrl: talk.imgURL,
                                  cacheManager: customCacheManager,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                  ),
                                ),
                              ),
                            ))),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
