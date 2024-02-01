import 'package:flutter/material.dart';
import 'challenge.dart';
import 'onlineusers.dart';
import 'package:pomo_rush/utils/preferences.dart';
import 'home.dart';
import 'leaderboard.dart';
import '../models/store.dart';
import 'store_screen.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;

  String title = "PomoRush";

  late final Store store;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    store = Store();

    _pages = [
      const WelcomePage(),
      StoreScreen(store: store,),
      const OnlineActiveUsers(),
      const LeaderBoard(),
      const ChallengeListScreen()
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      switch (index) {
        case 0:
          setState(() {
            title = "Home";
          });
          break;

        case 1:
          setState(() {
            title = "Store";
          });
          break;

        case 2:
          setState(() {
            title = "Users";
          });
          break;

        case 3:
          setState(() {
            title = "Ranking";
          });
          break;

        case 4:
          setState(() {
            title = "Challenge List";
          });
          break;

        default:
          setState(() {
            title = "Welcome to POMORUSH";
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      appBar: AppBar(
        backgroundColor: Styles.pomodoroPrimaryColor,
        title: Text(title,
            style: TextStyle(color:Colors.white,)
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Styles.pomodoroPrimaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_grocery_store),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Rank',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows_rounded),
            label: 'Challenge',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
