import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class ForgotEmailAddress extends StatefulWidget {
  const ForgotEmailAddress({Key? key}) : super(key: key);

  @override
  State<ForgotEmailAddress> createState() => _ForgotEmailAddressState();
}

class _ForgotEmailAddressState extends State<ForgotEmailAddress> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NewGradientAppBar(
        centerTitle: true,
        title: Text('お問い合わせ'),
        gradient: LinearGradient(
          colors: [Colors.lightBlue.shade200, Colors.deepPurple.shade200],
        ),
      ),
    );
  }
}
