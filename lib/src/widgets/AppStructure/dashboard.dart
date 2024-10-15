import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lotengo/src/utils/MyPainter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  static String tag = '/DemoDashboard2';

  @override
  DashboardState createState() => DashboardState();
}

const CURVE_HEIGHT = 100.0;
const AVATAR_RADIUS = CURVE_HEIGHT * 0.8;
const fontMedium = 'Medium';

String userName = '';

class DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();

    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        //header
        Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 170,
              child: CustomPaint(painter: MyPainter()),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.person_pin, color: Colors.white),
                        onPressed: () {
                          //finish(context);
                        },
                      ),
                      Text(
                        'Bienvenido $userName',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              transform: Matrix4.translationValues(0.0, 60.0, 0.0),
              child: Padding(
                padding: EdgeInsets.only(left: 10, right: 15, top: 30),
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 255, 255, 255),
                      borderRadius: BorderRadius.all(Radius.circular(26))),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/data/images/loterianame2.png',
                          fit: BoxFit.cover,
                          height: 120,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
