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
    final Size size = MediaQuery.of(context).size;
    return ChangeNotifierProvider.value(
      value: TalkModel()..getTalk(roomID),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(title: const Text('トーク')),
          backgroundColor: const Color(0xffFCFAF2),
          body: Consumer<TalkModel>(builder: (context, model, child) {
            return Scaffold();
          }),
          bottomNavigationBar:
              Consumer<TalkModel>(builder: (context, model, child) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                child: Center(
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            //  await model.pickImage();
                            //   imageFile = model.imageFile;
                            //  print(model.imageFile);
                          },
                          icon: const Icon(
                            Icons.picture_as_pdf,
                            color: Color(0xffFCFAF2),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: SizedBox(
                          height: size.height * 0.1,
                          width: size.width * 0.7,
                          child: TextField(
                              onChanged: (value) => model.comment = value,
                              style: GoogleFonts.sawarabiMincho(
                                fontSize: 12,
                                color: const Color(0xffFCFAF2),
                              ),
                              maxLength: 128,
                              controller: commentController,
                              decoration: InputDecoration(
                                counterStyle: GoogleFonts.sawarabiMincho(
                                    color: const Color(0xffFCFAF2)),
                                labelText: 'メッセージを入力',
                                alignLabelWithHint: true,
                                labelStyle: GoogleFonts.sawarabiMincho(
                                    color: const Color(0xffFCFAF2)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xffFCFAF2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xffFCFAF2), width: 3.0),
                                ),
                              )),
                        ),
                      ),
                      model.isLoading
                          ? const SizedBox()
                          : IconButton(
                              onPressed: model.isLoading ? null : () async {},
                              icon: const Icon(
                                Icons.send,
                                color: Color(0xffFCFAF2),
                              ))
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
