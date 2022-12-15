// ignore_for_file: must_be_immutable, missing_return, use_build_context_synchronously

import 'dart:io';
import 'dart:math';
import 'package:chat_app_study/domain/talk.dart';
import 'package:chat_app_study/presentation/login/login.dart';
import 'package:chat_app_study/presentation/talk_page/talk_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//File imageFile;

class PicturePage extends StatelessWidget {
  PicturePage(
      {super.key,
      required this.imageFile,
      required this.size,
      required this.roomID,
      required this.uid});

  late File? imageFile;
  late Size size;
  late String roomID;
  late String uid;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: TalkModel(),
        child: Consumer<TalkModel>(builder: (context, model, child) {
          model.imageFile = imageFile;
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black12,
            ),
            body: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: size.width - 200,
                        minHeight: size.height - 200),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        imageFile!,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                model.isSending == true
                    ? Center(
                        child: Container(
                          alignment: Alignment.center,
                          width: 300,
                          height: 300,
                          child: const CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox.square(),
              ],
            ),
            floatingActionButton: model.isSending == false
                ? FloatingActionButton(
                    child: const Icon(Icons.send),
                    onPressed: () async {
                      try {
                        model.startSend();
                        await model.addImage(roomID, uid);
                      } catch (e) {
                        print(e);
                      } finally {
                        model.endSend();
                      }
                      model.imageFile = null;
                      Navigator.of(context).pop();
                    },
                  )
                : SizedBox.square(),
          );
        }));
  }
}
