// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_friend_model.dart';

// ignore: must_be_immutable
class AddFriendPage extends StatelessWidget {
  AddFriendPage({super.key, required this.uid});
  String uid;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider.value(
        value: AddFriendModel(),
        child: Consumer<AddFriendModel>(builder: (context, model, child) {
          return Scaffold(
              appBar: AppBar(
                title: const Text('友達検索'),
              ),
              body: GestureDetector(
                onTap: () {
                  primaryFocus?.unfocus();
                },
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: size.width,
                    height: size.height * 0.8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('IDで検索'),
                        ),
                        SizedBox(
                          width: size.width * 0.8,
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: "IDを入力",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  print(model.uniquID);
                                  model.uniquID = controller.text;
                                  await model.getFriendDada(model.uniquID, uid);
                                  await showDialog(
                                      context: context,
                                      builder: ((context) {
                                        return AlertDialog(
                                          title: Column(
                                            children: [
                                              model.firendData['photUrl'] !=
                                                      null
                                                  ? Container(
                                                      height: 55,
                                                      width: 55,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              fit: BoxFit.fill,
                                                              image: NetworkImage(
                                                                  model.firendData[
                                                                      'photUrl']))))
                                                  : Container(
                                                      height: 55,
                                                      width: 55,
                                                      decoration: const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              fit: BoxFit.fill,
                                                              image: AssetImage(
                                                                  'images/user.png')))),
                                              Text(model.firendData['name']),
                                            ],
                                          ),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () async {
                                                  await model.addFiriend(
                                                      model.firendData, uid);
                                                  await showDialog(
                                                      context: context,
                                                      builder: ((context) {
                                                        return const AlertDialog(
                                                          title: Text('追加しました'),
                                                        );
                                                      }));
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('追加する'))
                                          ],
                                        );
                                      }));
                                } catch (e) {
                                  final snackBar = SnackBar(
                                    backgroundColor: const Color(0xffD0104C),
                                    content: Text(e.toString()),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              },
                              child: const Text('検索')),
                        )
                      ],
                    ),
                  ),
                ),
              ));
        }));
  }
}
