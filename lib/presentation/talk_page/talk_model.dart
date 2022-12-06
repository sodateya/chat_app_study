import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/talk.dart';

class TalkModel extends ChangeNotifier {
  List<Talk> talks = [];
  final firestore = FirebaseFirestore.instance;
  int documentLimit = 13;
  late DocumentSnapshot lastDocument;
  late String message;

  Future getTalk() async {
    print('get');
  }
}
