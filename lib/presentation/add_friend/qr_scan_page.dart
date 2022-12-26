import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xff8171D3), Color(0xff9DD3E4)] //グラデーションの設定
                  )),
        ),
        title: const Text('QRコードをスキャンしてください'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  // QRコードを読み取る枠の部分
  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 20,
          borderLength: 60,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      print(scanData.code.toString());
      controller.pauseCamera();
      print('ready');
      check(scanData.code.toString());
      controller.resumeCamera();
    });
  }

  Future<void> check(String data) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('user')
          .where('RQpass', isEqualTo: data)
          .get();
      final length = doc.docs.length;
      if (length == 0) {
        // ignore: use_build_context_synchronously
        await await showDialog(
            context: context,
            builder: ((context) {
              return const AlertDialog(
                title: Text('該当するユーザーが見つかりません'),
              );
            }));
      } else {
        print(doc.docs.first.data()['name']);
        Navigator.pop(context, doc.docs.first.data());
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: ((context) {
            return const AlertDialog(
              title: Text('error'),
            );
          }));
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {}
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
}
