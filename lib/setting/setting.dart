import 'package:chat_app_study/home/home_model.dart';
import 'package:chat_app_study/login/login.dart';
import 'package:chat_app_study/setting/setting_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatelessWidget {
  SettingPage({super.key, required this.auth});
  FirebaseAuth auth;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider.value(
      value: SettingModel(),
      child: Consumer<SettingModel>(builder: (context, model, child) {
        return Scaffold(
            body:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            width: size.width,
            child: ElevatedButton(
                onPressed: () async {
                  await GoogleSignIn().signOut();
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) {
                    return Login();
                  }), (route) => false);
                },
                child: const Text('ログアウト')),
          )
        ]));
      }),
    );
  }
}
