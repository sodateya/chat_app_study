import 'package:chat_app_study/my_profile/my_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyProfilePage extends StatelessWidget {
  MyProfilePage({super.key, required this.uid});
  String uid;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider.value(
      value: MyProfileModel()..getMyData(uid),
      child: Consumer<MyProfileModel>(builder: (context, model, child) {
        return Scaffold(
            appBar: AppBar(
              title: Text('マイページ'),
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
                                          image:
                                              AssetImage('images/user.png')))),
                          Text(model.userInfo['name']),
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
                  },
                  child: const Text('確定'))
            ],
            actionsAlignment: MainAxisAlignment.center,
          );
        }));
  }
}
