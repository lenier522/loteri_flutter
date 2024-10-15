import 'package:lotengo/src/pages_buttom_navigation/profile_screen.dart';
import 'package:lotengo/src/pages_buttom_navigation/resultList_screen.dart';
import 'package:lotengo/src/pages_buttom_navigation/search_screen.dart';
import 'package:lotengo/src/pages_buttom_navigation/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:lotengo/src/widgets/AppStructure/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;

  final List<Widget> _pages = [
    ResultListScreen(),
    StatisticsScreen(),
    SearchScreen(),
    LoginScreen()
    //Container() // Placeholder for Profile/Login screen
  ];

  final List<Widget> _pages2 = [
    ResultListScreen(),
    StatisticsScreen(),
    SearchScreen(),
    ProfileScreen()
    //Container() // Placeholder for Profile/Login screen
  ];

  Widget verificarLoguin() {
    if (_isLoggedIn) {
      return ProfileScreen();
    } else {
      return LoginScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  void _onItemTapped(int index) async {

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.red,
        body: Column(
          children: [
            Dashboard(),
            const SizedBox(
              height: 45,
            ),
            Expanded(
              child: _selectedIndex == 3 && _isLoggedIn
                  //? ProfileScreen() // Mostrar el perfil si está logueado
                  ? _pages2[
                      _selectedIndex] // Mostrar el perfil si está logueado
                  : _pages[_selectedIndex],
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Estadísticas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Buscar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: appStore.primaryColor,
          unselectedItemColor: const Color.fromARGB(255, 83, 83, 83),
          onTap: _onItemTapped,
        ),
      );
  }
}
