// ignore_for_file: must_be_immutable, missing_return

import 'dart:io';
import 'package:chat_app_study/domain/talk.dart';
import 'package:chat_app_study/presentation/talk_page/talk_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

//File imageFile;

class TalkPage extends StatelessWidget {
  TalkPage({super.key, required this.roomID});
  late String roomID;
  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider.value(
        value: TalkModel(), //..getTalk(roomID),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
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
            body: Consumer<TalkModel>(builder: (context, model, child) {
              return Stack(
                children: [
                  ListView.builder(
                    // controller: scrollController
                    //   ..addListener(getMore),
                    itemCount: 5,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return const TalkTile();
                    },
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
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
                                    const Expanded(
                                      child: Scrollbar(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 15),
                                          child: TextField(
                                            maxLines: 10,
                                            minLines: 1,
                                            decoration: InputDecoration(
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
                              onPressed: () {},
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ));
  }
}

class TalkTile extends StatelessWidget {
  const TalkTile({super.key});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ChangeNotifierProvider.value(
        value: TalkModel()..getTalk(),
        child: Consumer<TalkModel>(builder: (context, model, child) {
          return SizedBox(
              width: size.width * 0.8,
              child: const ListTile(
                title: Text('aaa'),
              ));
        }));
  }
}
