// ignore_for_file: must_be_immutable, missing_return, use_build_context_synchronously

import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_study/domain/talk.dart';
import 'package:chat_app_study/presentation/login/login.dart';
import 'package:chat_app_study/presentation/talk_page/talk_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//File imageFile;

class PictureListPage extends StatelessWidget {
  PictureListPage({super.key, required this.size, required this.roomID});

  late Size size;
  late String roomID;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: TalkModel()..getPicture(roomID),
        child: Consumer<TalkModel>(builder: (context, model, child) {
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
              title: const Text('写真一覧'),
            ),
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, //カラム数
              ),
              itemCount: model.images.length, //要素数
              itemBuilder: (context, index) {
                //要素を戻り値で返す
                return CachedNetworkImage(
                  imageUrl: model.images[index].imgURL,
                  fit: BoxFit.contain,
                );
              },
              shrinkWrap: true,
            ),
          );
        }));
  }
}
