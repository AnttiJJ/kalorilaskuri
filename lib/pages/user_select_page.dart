import 'package:flutter/material.dart';
import 'package:kalorilaskuri/notifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSelectPage extends StatelessWidget {
  const UserSelectPage({super.key});

  void _selectUser(String user) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', user);

      userSelectedNotifier.value = user;
    } catch (e) {
      print(e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => _selectUser('Kati'),
            child: Text('Kati'),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _selectUser('Antti'),
            child: Text('Antti'),
          ),
        ],
      ),
    );
  }
}
