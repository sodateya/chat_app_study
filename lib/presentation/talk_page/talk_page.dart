// ignore_for_file: must_be_immutable, missing_return

import 'dart:io';
import 'package:chat_app_study/presentation/talk_page/talk_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

//File imageFile;
TextEditingController commentController = TextEditingController();

class TalkPage extends StatelessWidget {
  TalkPage({super.key, required this.roomID});
  late String roomID;

  @override
  Widget build(BuildContext context) {
    List testList = ['a', 'b', 'c', 'd', 'e'];
    final Size size = MediaQuery.of(context).size;
    return ChangeNotifierProvider.value(
      value: TalkModel(), //..getTalk(roomID),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(title: const Text('トーク')),
          body: Consumer<TalkModel>(builder: (context, model, child) {
            return ListView.builder(
              // controller: scrollController
              //   ..addListener(getMore),
              itemCount: 5,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(testList[index]),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
