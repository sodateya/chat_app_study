import 'package:chat_app_study/presentation/my_profile/my_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyProfilePage extends StatelessWidget {
  MyProfilePage({super.key, required this.uid});
  String uid;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: MyProfileModel()..getMyData(uid),
      child: Consumer<MyProfileModel>(builder: (context, model, child) {
        final size = MediaQuery.of(context).size;
        return Scaffold(
            appBar: AppBar(
              title: const Text('マイページ'),
            ),
            body: SizedBox(
              width: size.width,
              height: size.height,
              child: model.userInfo.isEmpty
                  ? Container(
                      alignment: Alignment.center,
                      width: 50,
                      height: 50,
                      child: const CircularProgressIndicator(),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Row(
                            children: [
                              model.userInfo['photUrl'] != null
                                  ? Container(
                                      alignment: Alignment.center,
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(
                                                  model.userInfo['photUrl']))))
                                  : Container(
                                      alignment: Alignment.center,
                                      height: 100,
                                      width: 100,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: AssetImage(
                                                  'images/user.png')))),
                              IconButton(
                                  onPressed: () async {
                                    await model.pickImage();
                                  },
                                  icon: const Icon(Icons.picture_as_pdf))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(model.userInfo['name']),
                              IconButton(
                                  onPressed: () {
                                    nameChangeDialog(context, model);
                                  },
                                  icon: Icon(Icons.edit))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(model.userInfo['uniquID'] == ""
                                  ? 'ID : IDはまだ登録されていません'
                                  : 'ID : ${model.userInfo['uniquID']}'),
                              IconButton(
                                  onPressed: () {
                                    idChangeDialog(context, model);
                                  },
                                  icon: Icon(Icons.edit))
                            ],
                          ),
                        ]),
            ));
      }),
    );
  }

  Future idChangeDialog(BuildContext context, MyProfileModel model) async {
    TextEditingController controller = TextEditingController();
    showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            title: const Text('新しいIDを入力してください'),
            content: TextField(
              controller: controller,
            ),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    try {
                      model.uniquID = controller.text;
                      await model.updataUniquID(uid);
                      Navigator.of(context).pop();
                      showDialog(
                          context: context,
                          builder: ((context) {
                            return const AlertDialog(
                              title: Text('変更しました'),
                            );
                          }));
                    } catch (e) {
                      showDialog(
                          context: context,
                          builder: ((context) {
                            return AlertDialog(
                              title: Text(
                                e.toString(),
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            );
                          }));
                    }
                  },
                  child: const Text('確定'))
            ],
            actionsAlignment: MainAxisAlignment.center,
          );
        }));
  }

  Future nameChangeDialog(BuildContext context, MyProfileModel model) async {
    TextEditingController controller = TextEditingController();
    showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            title: const Text('新しい名前を入力してください'),
            content: TextField(
              controller: controller,
            ),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    model.name = controller.text;
                    await model.updataName(uid);
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: ((context) {
                          return const AlertDialog(
                            title: Text('変更しました'),
                          );
                        }));
                  },
                  child: const Text('確定'))
            ],
            actionsAlignment: MainAxisAlignment.center,
          );
        }));
  }
}
