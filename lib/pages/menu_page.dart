import 'package:flutter/material.dart';
import 'package:kalorilaskuri/notifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  void clearUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');

    userSelectedNotifier.value = '';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(leading: Icon(Icons.menu_book), title: Text('Ruokalista')),
        ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          leading: Icon(Icons.person),
          title: Text('Vaihda käyttäjää'),
          onTap: () => clearUser(),
        ),
      ],
    );
  }
}
