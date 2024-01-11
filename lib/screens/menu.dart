import 'package:flutter/material.dart';
import 'challenge.dart';
import 'onlineusers.dart';
import 'package:pomo_rush/utils/preferences.dart';
import 'home.dart';
import 'leaderboard.dart';
import 'package:pomo_rush/screens/moneytimer.dart';
import 'store.dart';
import 'store_screen.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;

  String title = "PomoGame";

  // Create an instance of the Store class
  late final Store _store;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _store = Store();

    _pages = [
      const WelcomePage(),
      const MoneyTimerWidget(),
      StoreScreen(store: _store),
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
            title = "Money Earning Timer";
          });
          break;

        case 2:
          setState(() {
            title = "Store";
          });
          break;

        case 3:
          setState(() {
            title = "Users";
          });
          break;

        case 4:
          setState(() {
            title = "Leaderboard";
          });
          break;

        case 5:
          setState(() {
            title = "Challenge List";
          });
          break;

        default:
          setState(() {
            title = "PomoGame";
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
        title: Text(title),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Styles.pomodoroPrimaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Money',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_grocery_store),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows),
            label: 'Challenge',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
