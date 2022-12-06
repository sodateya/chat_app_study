import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_model.dart';

// ignore: must_be_immutable
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: HomeModel(),
      child: Consumer<HomeModel>(builder: (context, model, child) {
        return Scaffold(
            body: model.screens[model.selectedIndex],
            // body: IndexedStack(
            //   index: model.selectedIndex,
            //   children: model.screens,
            // ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: model.selectedIndex,
              onTap: model.onItemTapped,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle), label: '友達リスト'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble), label: 'トーク'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: '設定'),
                BottomNavigationBarItem(icon: Icon(Icons.check), label: '友達申請'),
              ],
              type: BottomNavigationBarType.fixed,
            ));
      }),
    );
  }
}
