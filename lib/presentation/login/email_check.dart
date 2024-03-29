// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

import 'name_set.dart';

// ignore: must_be_immutable
class Emailcheck extends StatefulWidget {
  // 呼び出し元Widgetから受け取った後、変更をしないためfinalを宣言。
  final String email;
  final String pswd;
  final int from; //1 → アカウント作成画面から    2 → ログイン画面から

  Emailcheck(
      {Key? key, required this.email, required this.pswd, required this.from})
      : super(key: key);
  @override
  _Emailcheck createState() => _Emailcheck();
}

class _Emailcheck extends State<Emailcheck> {
  final _auth = FirebaseAuth.instance;
  late UserCredential _result;
  late String _nocheckText;
  late String _sentEmailText;
  // ignore: non_constant_identifier_names
  int _btn_click_num = 0;

  @override
  Widget build(BuildContext context) {
    // 前画面から遷移後の初期表示内容
    if (_btn_click_num == 0) {
      if (widget.from == 1) {
        // アカウント作成画面から遷移した時
        _nocheckText = '';
        _sentEmailText = '${widget.email}\nに確認メールを送信しました。';
      } else {
        _nocheckText = 'まだメール確認が完了していません。\n確認メール内のリンクをクリックしてください。';
        _sentEmailText = '';
      }
    }

    return Scaffold(
      // メイン画面
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 確認メール未完了時のメッセージ
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                  child: Text(
                    _nocheckText,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

                // 確認メール送信時のメッセージ
                Text(_sentEmailText),

                // 確認メールの再送信ボタン
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 30.0),
                  child: ButtonTheme(
                    minWidth: 200.0,
                    // height: 100.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          primary: Colors.grey),

                      onPressed: () async {
                        _result = await _auth.signInWithEmailAndPassword(
                          email: widget.email,
                          password: widget.pswd,
                        );

                        _result.user?.sendEmailVerification();
                        setState(() {
                          _btn_click_num++;
                          _sentEmailText = '${widget.email}\nに確認メールを送信しました。';
                        });
                      },

                      // ボタン内の文字や書式
                      child: const Text(
                        '確認メールを再送信',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                // メール確認完了のボタン配置（Home画面に遷移）
                ButtonTheme(
                  minWidth: 350.0,
                  // height: 100.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      primary: Colors.blue,
                    ),

                    onPressed: () async {
                      _result = await _auth.signInWithEmailAndPassword(
                        email: widget.email,
                        password: widget.pswd,
                      );

                      // Email確認が済んでいる場合は、Home画面へ遷移
                      if (_result.user!.emailVerified) {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NameSetPage(user: _result.user),
                            ));
                      } else {
                        // print('NG');
                        setState(() {
                          _btn_click_num++;
                          _nocheckText =
                              "まだメール確認が完了していません。\n確認メール内のリンクをクリックしてください。";
                        });
                      }
                    },

                    // ボタン内の文字や書式
                    child: const Text(
                      'メール確認完了',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                ElevatedButton(
                  child: const Text('戻る'),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
