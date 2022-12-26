import 'package:chat_app_study/main.dart';
import 'package:chat_app_study/presentation/login/login_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

TextEditingController controller = TextEditingController();

class NameSetPage extends StatelessWidget {
  NameSetPage({super.key, required this.user});
  User? user;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider.value(
      value: LoginModel(),
      child: Consumer<LoginModel>(builder: (context, model, child) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('名前を設定'),
            ),
            body:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextField(controller: controller),
              ElevatedButton(
                  onPressed: () async {
                    model.name = controller.text;
                    await setDb(model, context, user!);
                  },
                  child: const Text('登録'))
            ]));
      }),
    );
  }

  Future setDb(LoginModel model, BuildContext context, User user) async {
    try {
      await model.createUserDatabase(user);
      await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return MyApp();
      }), (route) => false);
    } catch (e) {
      final snackBar = SnackBar(
        backgroundColor: const Color(0xffD0104C),
        content: Text(e.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
