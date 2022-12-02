// ignore_for_file: use_build_context_synchronously

import 'package:chat_app_study/presentation/home/home.dart';
import 'package:chat_app_study/presentation/login/registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'email_check.dart';
import 'forgot_email_address.dart';
import 'forgot_password.dart';
import 'inquiry_otoiawase.dart';
import 'login_model.dart';

class Login extends StatelessWidget {
  late GoogleSignInAccount googleUser;
  late GoogleSignInAuthentication googleAuth;
  late AuthCredential credential;

  String login_Email = ""; // 入力されたメールアドレス
  String login_Password = "";

  Login({super.key}); // 入力されたパスワード

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider.value(
        value: LoginModel(),
        child: Consumer<LoginModel>(builder: (context, model, child) {
          return Scaffold(
            body: GestureDetector(
              onTap: () {
                primaryFocus?.unfocus();
              },
              child: SingleChildScrollView(
                child: SafeArea(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(height: 60),

                              Text("LOGO",
                                  style: TextStyle(
                                      fontSize: 60.0,
                                      fontWeight: FontWeight.bold,
                                      foreground: Paint()
                                        ..shader = LinearGradient(
                                          colors: <Color>[
                                            Colors.pinkAccent.shade400,

                                            Colors.pinkAccent.shade100,

                                            //add more color here.
                                          ],
                                        ).createShader(const Rect.fromLTWH(
                                            0.0, 0.0, 200.0, 100.0)))),

                              // メールアドレスの入力フォーム

                              const SizedBox(height: 40),
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                  ),
                                  labelText: 'メールアドレス',
                                ),
                                onChanged: (String value) {
                                  login_Email = value;
                                },
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                // パスワードを非表示にする
                                obscureText: true,
                                keyboardType: TextInputType.visiblePassword,

                                decoration: const InputDecoration(
                                  labelStyle: TextStyle(fontSize: 12),
                                  labelText: 'パスワード',
                                ),
                                onChanged: (String value) {
                                  login_Password = value;
                                },
                              ),
                              const SizedBox(height: 24),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    20.0, 0, 20.0, 5.0),
                                child: Text(
                                  model.infoText,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                              SizedBox(
                                height: 32,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Checkbox(
                                      value: model.agreeToTerms,
                                      onChanged: (value) {
                                        model.isAgreeToTerms(value);
                                      },
                                    ),
                                    // TODO(kenta-wakasa): ご利用規約ページに遷移する
                                    const Text(
                                      'ご利用規約',
                                      style: TextStyle(
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  clipBehavior: Clip.antiAlias,
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
                                                builder: (context) =>
                                                    Emailcheck(
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
                                                builder: (context) =>
                                                    Emailcheck(
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
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.deepPurple.shade200,
                                            Colors.deepPurpleAccent,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 15,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text('メールアドレス'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  clipBehavior: Clip.antiAlias,
                                  onPressed: () async {
                                    googleUser =
                                        (await GoogleSignIn().signIn())!;
                                    googleAuth =
                                        await googleUser.authentication;
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
                                              builder: (context) =>
                                                  const Home(),
                                            ));
                                      } else {
                                        final user = result.user;
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Home(),
                                            ));
                                      }
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.lightBlue.shade400,
                                            Colors.lightBlue.shade700,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 15,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text('Googleログイン'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  clipBehavior: Clip.antiAlias,
                                  onPressed: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        fullscreenDialog: true,
                                        builder: (BuildContext context) =>
                                            const Registration(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.grey.shade300,
                                            Colors.grey.shade300,
                                            Colors.grey.shade300,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Container(
                                        // 上と下は余白なし
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 15,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '新規登録',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ForgotPassword(),
                                    ),
                                  );
                                },
                                child: const Text('パスワードを忘れた方はこちら'),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotEmailAddress(),
                                    ),
                                  );
                                },
                                child: const Text('メールアドレスを忘れた方はお問合せください'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Inquiry(),
                                    ),
                                  );
                                },
                                child: const Text('お問合せ'),
                              ),
                              // TextButton(
                              //   child: const Text('上記メールアドレスにパスワード再設定メールを送信'),
                              //   onPressed: () => model.auth
                              //       .sendPasswordResetEmail(email: login_Email),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ),
            ),
          );
        }));
  }
}
