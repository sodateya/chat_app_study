import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_study/presentation/my_profile/my_profile_model.dart';
import 'package:chat_app_study/presentation/talk_page/picture_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQRcodePage extends StatelessWidget {
  MyQRcodePage({super.key, required this.uid});
  String uid;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: MyProfileModel()..getMyData(uid),
      child: Consumer<MyProfileModel>(builder: (context, model, child) {
        final size = MediaQuery.of(context).size;
        return SizedBox(
          width: size.width,
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                      iconSize: 35,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        QrImage(
                          data: '${model.userInfo['QRpass']}',
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            'QRコードを使って友達を追加しましょう',
                            style: TextStyle(
                                color: Color.fromARGB(255, 66, 65, 65)),
                          ),
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: const BorderSide(
                                color: Colors.grey, //枠線!
                              ),
                            ),
                            onPressed: () async {
                              await model.updateQRpass(uid);
                            },
                            child: SizedBox(
                              width: 60,
                              child: Row(
                                children: const [
                                  Icon(Icons.replay_outlined,
                                      color: Color.fromARGB(255, 66, 65, 65)),
                                  Text('更新',
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 66, 65, 65)))
                                ],
                              ),
                            )),
                      ]),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
