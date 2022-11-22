import 'package:chat_app_study/home/home_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider.value(
      value: HomeModel(),
      child: Consumer<HomeModel>(builder: (context, model, child) {
        return Scaffold(
            body: model.screens[model.selectedIndex],
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
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_add_alt_1), label: '追加'),
              ],
              type: BottomNavigationBarType.fixed,
            ));
      }),
    );
  }
}
