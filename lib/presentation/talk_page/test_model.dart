// ignore_for_file: missing_return

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:intl/intl.dart';

class TestModel extends ChangeNotifier {
  String udid = 'UDID';
  String token = '';
  late String title;
  DateTime dateTime = DateTime.now(); //カレンダーで決めた日にち(初期値は当日)
  TimeOfDay time = TimeOfDay.now(); //時計で決めた時の時間(初期値は現在時刻)
  DateTime time2 = DateTime.now(); //ピッカーで決めた時の時間(初期値は現在時刻)
  late DateTime finalDateTime; //最終的な日と時間

  Future getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print(token);
    final data = ClipboardData(text: token);
    await Clipboard.setData(data);
    this.token = token!;
  }

  // Future printUuid() async {
  //   String udid = await FlutterUdid.udid;
  //   this.udid = udid;
  //   notifyListeners();
  //   print(udid);
  // }

  void httpPush(String token, String body) async {
    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('pushSubmitFromApp');
    await callable.call({'token': token, 'body': body});
    notifyListeners();
  }

  Future push(String text, String token) async {
    final functions = FirebaseFunctions.instanceFor(region: 'asia-northeast1');
    final callable = functions.httpsCallable('pushSubmitFromApp');
    await callable({'id': text, 'token': token});
    notifyListeners();
  }

  //大まかな流れ
  //　①queued_writes へ送る
  //　②Functions(Schedule Firestore Writes)で１分に１回queued_writesコレクションのstateがPENDINGのドキュメントを監視
  //　③PENDINGのドキュメントのdeliverTimeの時間になる
  //　④dataの内容をcollectionへ送信

  Future addTo() async {
    final targetTime = finalDateTime;
    print(targetTime);
    final db = FirebaseFirestore.instance.collection('queued_writes');
    await db.add({
      'state': "PENDING",
      'deliverTime': targetTime, //送る時間
      'data': {'title': 'テスト', 'message': '時刻テスト'}, //送る内容
      'collection':
          'test//subaTest' //送るコレクション名(サブコレクションの場合：'メインコレクション/ドキュメントID〈自動の場合はなし〉/サブコレクション名')
    });
    print('完了');
  } // firebaseのqueued_writesコレクションへ送信

  Future datePicker(BuildContext context) async {
    dynamic dateFormat = DateFormat("yyyy年MM月dd日").format(dateTime);
    final pickedTime = await showDatePicker(
        locale: const Locale("ja"), //国を設定(現在設定値：日本)
        context: context,
        initialDate: dateTime, //日にちの初期値を設定(現在設定値：当日)
        firstDate: DateTime.now(), //選択可能な年の最小値を設定(現在設定値：現在の年まで選択可能)※過去を選択させないため
        lastDate: DateTime(2999)); //選択可能な年の最大値を設定(現在設定値：2999まで選択可能)
    notifyListeners();
    if (pickedTime != null && pickedTime != dateTime) {
      dateTime = pickedTime;
      dateFormat = DateFormat("yyyy年MM月dd日").format(pickedTime);
      await dteTimeDecision();
      notifyListeners();
    }
  } //カレンダーを起動して日にち選択timePicker(時計UI)と一緒に使う

  Future datePicker2(BuildContext context) async {
    dynamic dateFormat = DateFormat("yyyy年MM月dd日").format(dateTime);
    final pickedTime = await showDatePicker(
        locale: const Locale("ja"), //国を設定(現在設定値：日本)
        context: context,
        initialDate: dateTime, //日にちの初期値を設定(現在設定値：当日)
        firstDate: DateTime.now(), //選択可能な年の最小値を設定(現在設定値：現在の年まで選択可能)※過去を選択させないため
        lastDate: DateTime(2999)); //選択可能な年の最大値を設定(現在設定値：2999まで選択可能)
    notifyListeners();
    if (pickedTime != null && pickedTime != dateTime) {
      dateTime = pickedTime;
      dateFormat = DateFormat("yyyy年MM月dd日").format(pickedTime);
      await dteTimeDecision2();
      notifyListeners();
    }
  } //カレンダーを起動して日にち選択timePicker2(ピッカー)と一緒に使う

  Future timePicker(BuildContext context) async {
    final TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: time, //時間の初期値を設定(現在設定値：現在時刻)
    );
    if (timePicked != null && timePicked != time) {
      time = timePicked;
      await dteTimeDecision();
      notifyListeners();
    }
  } //時計UIで時間選択

  Future timePicker2(BuildContext context) async {
    Picker(
      adapter: DateTimePickerAdapter(
          type: PickerDateTimeType.kHM,
          value: time2, //時間の初期値を設定(現在設定値：現在時刻)
          customColumnType: [3, 4]),
      title: Text("時間を設定"),
      onConfirm: (Picker picker, List value) async {
        time2 = DateTime.utc(0, 0, 0, value[0], value[1]);
        dteTimeDecision2();
        notifyListeners();
      },
    ).showModal(context);
  } //ピッカーで時間選択

  Future dteTimeDecision() async {
    finalDateTime = DateTime(
        dateTime.year, dateTime.month, dateTime.day, time.hour, time.minute);
    print(finalDateTime);
  }

  Future dteTimeDecision2() async {
    finalDateTime = DateTime(
        dateTime.year, dateTime.month, dateTime.day, time2.hour, time2.minute);
    print(finalDateTime);
  }
}
