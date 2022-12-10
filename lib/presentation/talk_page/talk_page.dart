// ignore_for_file: must_be_immutable, missing_return, use_build_context_synchronously

import 'package:chat_app_study/domain/talk.dart';
import 'package:chat_app_study/presentation/talk_page/talk_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

//File imageFile;

class TalkPage extends StatelessWidget {
  TalkPage(
      {super.key, required this.roomID, required this.uid, required this.size});
  late String roomID;
  late String uid;
  late Size size;
  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print('reload');
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
                      onTap: () {},
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
                                ? myTalk(context, size, talks[index])
                                : otherTalk(context, size, talks[index]);
                          },
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      margin: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.photo_camera,
                                color: Colors.blueAccent),
                            onPressed: () {},
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
                                    child: Scrollbar(
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send,
                                color: Colors.blueAccent),
                            onPressed: () async {
                              await model.addMessage(roomID, uid);
                              FocusScope.of(ctx).unfocus();
                              commentController.clear();
                              model.message = '';
                              model.imgURL = '';
                            },
                          )
                        ],
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

Widget otherTalk(BuildContext context, Size size, Talk talk) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          children: [
            SizedBox(
              child: SizedBox(
                width: size.width * 0.8,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
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
                              style: GoogleFonts.sawarabiMincho(
                                color: const Color(0xffFCFAF2),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // SizedBox(
                        //   child: talk.read.length <= 1
                        //       ? const Text('')
                        //       : const Text('既読',
                        //           style: TextStyle(
                        //               fontSize: 12, color: Colors.grey),
                        //           textAlign: TextAlign.left),
                        // ),
                        SizedBox(
                          child: Text(
                              ' ${talk.createdAt.hour}:${talk.createdAt.minute}',
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
          ],
        ),
      ],
    ),
  );
}

Widget myTalk(BuildContext context, Size size, Talk talk) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          children: [
            SizedBox(
              child: SizedBox(
                width: size.width * 0.8,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Container(
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
                              style: GoogleFonts.sawarabiMincho(
                                color: const Color(0xffFCFAF2),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          child: talk.read.length <= 1
                              ? const Text('')
                              : const Text('既読',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.left),
                        ),
                        SizedBox(
                          child: Text(
                              ' ${talk.createdAt.hour}:${talk.createdAt.minute}',
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
          ],
        ),
      ],
    ),
  );
}
