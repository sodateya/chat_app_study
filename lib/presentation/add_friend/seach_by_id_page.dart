// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:chat_app_study/presentation/add_friend/add_friend_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class SearchByIdPage extends StatelessWidget {
  SearchByIdPage(this.size, this.uid, {Key? key}) : super(key: key);
  Size size;
  String uid;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: AddFriendModel(),
        child: Consumer<AddFriendModel>(builder: (context, model, child) {
          return SingleChildScrollView(
            child: SizedBox(
              width: size.width * 0.8,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: SizedBox(
                      child: TextFormField(
                        onChanged: (value) {
                          print(controller.text);
                          if (value == '') {
                            value = controller.text;
                            model.notInText();
                          } else {
                            value = controller.text;
                            model.inText();
                          }
                        },
                        controller: controller,
                        decoration: InputDecoration(
                          errorText: model.erroeMsg,
                          suffixIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              model.isInControllerText == false
                                  ? const SizedBox.shrink()
                                  : IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints:
                                          const BoxConstraints(), // これを追加
                                      onPressed: () {
                                        controller.clear();
                                        model.notInText();
                                        model.resetError();
                                        model.resetUserData();
                                      },
                                      icon: const Icon(Icons.clear),
                                    ),
                              IconButton(
                                constraints: const BoxConstraints(), // これを追加
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  model.resetError();
                                  model.resetUserData();
                                  await addFriendUseID(model, context);
                                },
                                icon: const Icon(Icons.search),
                              ),
                            ],
                          ),
                          labelText: "IDを入力",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  model.firendData != null && model.erroeMsg == null
                      ? Column(
                          children: [
                            model.firendData!['photUrl'] != null
                                ? Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: NetworkImage(
                                                model.firendData!['photUrl']))))
                                : Container(
                                    height: 80,
                                    width: 80,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: AssetImage(
                                                'images/user.png')))),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                model.firendData!['name'],
                                style: const TextStyle(fontSize: 25),
                              ),
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  await model.addFiriend(
                                      model.firendData!, uid);
                                },
                                child: const Text('追加する'))
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          );
        }));
  }

  Future addFriendUseID(AddFriendModel model, BuildContext context) async {
    try {
      print(model.uniquID);
      model.uniquID = controller.text;
      await model.getFriendDada(model.uniquID, uid);
      // await showDialog(
      //     context: context,
      //     builder: ((context) {
      //       return AlertDialog(
      //         title: Column(
      //           children: [
      //             model.firendData['photUrl'] != null
      //                 ? Container(
      //                     height: 55,
      //                     width: 55,
      //                     decoration: BoxDecoration(
      //                         shape: BoxShape.circle,
      //                         image: DecorationImage(
      //                             fit: BoxFit.fill,
      //                             image: NetworkImage(
      //                                 model.firendData['photUrl']))))
      //                 : Container(
      //                     height: 55,
      //                     width: 55,
      //                     decoration: const BoxDecoration(
      //                         shape: BoxShape.circle,
      //                         image: DecorationImage(
      //                             fit: BoxFit.fill,
      //                             image: AssetImage('images/user.png')))),
      //             Text(model.firendData['name']),
      //           ],
      //         ),
      //         actions: [
      //           ElevatedButton(
      //               onPressed: () async {
      //                 await model.addFiriend(model.firendData, uid);
      //                 await showDialog(
      //                     context: context,
      //                     builder: ((context) {
      //                       return const AlertDialog(
      //                         title: Text('追加しました'),
      //                       );
      //                     }));
      //                 Navigator.of(context).pop();
      //               },
      //               child: const Text('追加する'))
      //         ],
      //       );
      //     }));
    } catch (e) {
      model.catchError(e.toString());
    }
  }
}
