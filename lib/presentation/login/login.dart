// ignore_for_file: use_build_context_synchronously

import 'package:chat_app_study/presentation/home/home.dart';
import 'package:chat_app_study/presentation/login/registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'email_check.dart';
import 'login_model.dart';

class Login extends StatelessWidget {
  late GoogleSignInAccount googleUser;
  late GoogleSignInAuthentication googleAuth;
  late AuthCredential credential;

  String login_Email = ""; // 入力されたメールアドレス
  String login_Password = ""; // 入力されたパスワード

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider.value(
        value: LoginModel(),
        child: Consumer<LoginModel>(builder: (context, model, child) {
          return Scaffold(
            backgroundColor: const Color(0xffFCFAF2),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // メールアドレスの入力フォーム
                        Padding(
                            padding:
                                const EdgeInsets.fromLTRB(25.0, 0, 25.0, 0),
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: "メールアドレス"),
                              onChanged: (String value) {
                                login_Email = value;
                              },
                            )),

                        // パスワードの入力フォーム
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 0, 25.0, 10.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: "パスワード（8～20文字）"),
                            obscureText: true, // パスワードが見えないようRにする
                            maxLength: 20, // 入力可能な文字数
                            onChanged: (String value) {
                              login_Password = value;
                            },
                          ),
                        ),

                        // ログイン失敗時のエラーメッセージ
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 0, 20.0, 5.0),
                          child: Text(
                            model.infoText,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                        // ログインボタンの配置
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ButtonTheme(
                              minWidth: size.width * 0.45,
                              // height: 100.0,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      primary: Colors.blue[50]),

                                  // ボタンクリック後にアカウント作成用の画面の遷移する。
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        fullscreenDialog: true,
                                        builder: (BuildContext context) =>
                                            const Registration(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'アカウントを作成する',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  )),
                            ),
                            ButtonTheme(
                              minWidth: size.width * 0.45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  primary: const Color(0xff39bdcc),
                                ),

                                onPressed: () async {
                                  try {
                                    // メール/パスワードでログイン
                                    model.result = await model.auth
                                        .signInWithEmailAndPassword(
                                      email: login_Email,
                                      password: login_Password,
                                    );
                                    final isFirstLogin = model
                                        .result.additionalUserInfo!.isNewUser;

                                    // ログイン成功
                                    model.user =
                                        model.result.user!; // ログインユーザーのIDを取得

                                    // Email確認が済んでいる場合のみHome画面へ
                                    if (isFirstLogin) {
                                      if (model.user.emailVerified) {
                                        await model
                                            .createUserDatabase(model.user);
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Home(),
                                            ));
                                      } else {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Emailcheck(
                                                    email: login_Email,
                                                    pswd: login_Password,
                                                    from: 2,
                                                  )),
                                        );
                                      }
                                    } else {
                                      if (model.user.emailVerified) {
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Home(),
                                            ));
                                      } else {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Emailcheck(
                                                    email: login_Email,
                                                    pswd: login_Password,
                                                    from: 2,
                                                  )),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    print(e);
                                    // ログインに失敗した場合
                                    model.loginErrorMessage(e);
                                  }
                                },

                                // ボタン内の文字や書式
                                child: const Text(
                                  'ログイン',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // ログイン失敗時のエラーメッセージ
                        TextButton(
                          child: const Text('上記メールアドレスにパスワード再設定メールを送信'),
                          onPressed: () => model.auth
                              .sendPasswordResetEmail(email: login_Email),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SignInButton(
                              Buttons.Google,
                              text: 'Googleサインイン',
                              onPressed: () async {
                                googleUser = (await GoogleSignIn().signIn())!;
                                googleAuth = await googleUser.authentication;
                                credential = GoogleAuthProvider.credential(
                                  accessToken: googleAuth.accessToken,
                                  idToken: googleAuth.idToken,
                                );
                                try {
                                  final result = await model.auth
                                      .signInWithCredential(credential);
                                  final isFirstLogin =
                                      result.additionalUserInfo!.isNewUser;
                                  if (isFirstLogin) {
                                    final user = result.user;
                                    await model.createUserDatabase(user!);
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Home(),
                                        ));
                                  } else {
                                    final user = result.user;
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Home(),
                                        ));
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
  }
}
