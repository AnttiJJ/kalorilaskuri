import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kalorilaskuri/notifiers.dart';
import 'package:kalorilaskuri/pages/drinks_page.dart';
import 'package:kalorilaskuri/pages/extras_page.dart';
import 'package:kalorilaskuri/pages/foods_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  void clearUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');

    userSelectedNotifier.value = '';
  }

  Future<void> logOut() async {
    clearUser();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          leading: Icon(Icons.menu_book),
          title: Text('Ruokalista'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FoodsPage()),
            );
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          leading: Icon(Icons.breakfast_dining),
          title: Text('Lisukkeet'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ExtrasPage()),
            );
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          leading: Icon(Icons.coffee),
          title: Text('Juomat'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DrinksPage()),
            );
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          leading: Icon(Icons.person),
          title: Text('Vaihda käyttäjää'),
          onTap: () => clearUser(),
        ),
        ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          leading: Icon(Icons.logout),
          title: Text('Kirjaudu ulos'),
          onTap: () => logOut(),
        ),
      ],
    );
  }
}
