import 'package:flutter/material.dart';
import 'package:lotengo/src/pages/home_screen.dart';
import 'package:lotengo/src/pages/latest_results_screen.dart';
import 'package:lotengo/src/pages/login_screen.dart';
import 'package:lotengo/src/pages/register_screen.dart';
import 'package:lotengo/src/pages/result_screen.dart';
import 'package:lotengo/src/pages/user_list.dart';
import 'package:lotengo/src/pages_buttom_navigation/resultList_screen.dart';
import 'package:lotengo/src/widgets/AppStructure/WalkThrough.dart';
//import 'package:lotengo/src/widgets/AppStructure/bottom_navigation_screen.dart';

Map<String, WidgetBuilder> getApplicationRoutes() {

  return <String, WidgetBuilder>{
    
    '/walkthrough': (BuildContext context) => OnboardingScreen(),
    '/': (BuildContext context) => HomeScreen(),
    //'/': (BuildContext context) => BottomNavigationScreen(),
    '/listresult': (BuildContext context) => ResultListScreen(),
    '/login': (BuildContext context) => LoginScreen(),
    '/register': (BuildContext context) => RegisterScreen(),// Agregar Usuario
    'addresult': (BuildContext context) => ResultScreen(),// Agregar Resultado
    '/userlist': (BuildContext context) => UserListScreen(),// Mostrar listado usuarios
    '/last': (context) => LatestResultsScreen(), // Lista de Numeros
  };
}
