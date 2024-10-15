import 'package:flutter/material.dart';
import 'package:lotengo/src/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences? _prefs;

  bool dataPref = false;

  String initialRoute = "";

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        this._prefs = prefs;
        _loadStartedData();

        print('Error: $dataPref');

        if (dataPref == true) {
          initialRoute = '/';
        }else{
          initialRoute = '/walkthrough';
        }
      });
    });
  }

  void _loadStartedData() {
    setState(() {
      dataPref = _prefs?.getBool('WalkThrough_pref') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lotery LoTengo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      //home: const HomePage(),
      initialRoute: '/walkthrough',
      routes: getApplicationRoutes(),
    );
  }
}
