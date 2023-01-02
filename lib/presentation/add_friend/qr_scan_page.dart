import 'dart:io';

import 'package:chat_app_study/presentation/add_friend/add_friend_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'my_qr_page.dart';

class QRScanPage extends StatefulWidget {
  Size? size;
  String? uid;
  QRScanPage({Key? key, this.size, this.uid}) : super(key: key);

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
    return ChangeNotifierProvider.value(
        value: AddFriendModel(),
        child: Consumer<AddFriendModel>(builder: (context, model, child) {
          return Scaffold(
            body: Stack(
              children: [
                Column(
                  children: <Widget>[
                    Expanded(flex: 4, child: _buildQrView(context)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 60, left: 20),
                  child: IconButton(
                      iconSize: 30,
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close)),
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: widget.size!.width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black26,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(90),
                                            ),
                                          ),
                                          onPressed: () async {
                                            showMyQRCode();
                                          },
                                          child: SizedBox(
                                            width: 120,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.qr_code),
                                                Text('マイQRコード')
                                              ],
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await model.decode();
                                  await check(model.data);
                                },
                                icon: const Icon(
                                    Icons.photo_size_select_actual_rounded),
                                iconSize: 30,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
            bottomNavigationBar: const BottomAppBar(
              height: 200,
              child: Center(
                child: Text('QRコードをスキャンして友達追加などの機能を利用できます'),
              ),
            ),
          );
        }));
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
          .where('QRpass', isEqualTo: data)
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

  Future showMyQRCode() async {
    setState(() {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          context: context,
          builder: ((context) {
            return MyQRcodePage(uid: widget.uid!);
          }));
    });
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
