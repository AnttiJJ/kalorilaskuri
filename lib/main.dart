import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kalorilaskuri/firebase_options.dart';
import 'package:kalorilaskuri/notifiers.dart';
import 'package:kalorilaskuri/pages/calories_page.dart';
import 'package:kalorilaskuri/pages/meals_page.dart';
import 'package:kalorilaskuri/pages/menu_page.dart';
import 'package:kalorilaskuri/pages/user_select_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? user = prefs.getString('user');

  userSelectedNotifier.value = (user != null) ? user : '';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KAlorilaskuri',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    MealsPage(),
    CaloriesPage(),
    MenuPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: userSelectedNotifier,
      builder: (context, userSelected, child) {
        if (userSelected != '') {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text('KAlorilaskuri ($userSelected)'),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant),
                  label: 'Ateriat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bolt),
                  label: 'Kalorit',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'Valikko',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
            body: _pages[_selectedIndex],
          );
        }
        return Scaffold(body: UserSelectPage());
      },
    );
  }
}
