import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'get_uid_model.dart';

class GetUidPage extends StatefulWidget {
  const GetUidPage({super.key});

  @override
  State<GetUidPage> createState() => _GetUidPageState();
}

class _GetUidPageState extends State<GetUidPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: GetUidModel(),
        child: Consumer<GetUidModel>(builder: (context, model, child) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(model.uid),
                  ElevatedButton(
                      onPressed: () {
                        model.setUserw();
                      },
                      child: const Text('Uidを追加'))
                ],
              ),
            ),
          );
        }));
  }
}
