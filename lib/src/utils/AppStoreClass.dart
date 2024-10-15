import 'dart:ui';

import 'package:flutter/material.dart';

class AppStore {
  /* Color? textPrimaryColor;
  Color? iconColorPrimaryDark;
  Color? scaffoldBackground;
  Color? backgroundColor;
  Color? backgroundSecondaryColor;
  Color? appColorPrimaryLightColor;
  Color? textSecondaryColor;
  Color? appBarColor;
  Color? chipColor;
  Color? chipPrimaryColor;
  Color? iconColor;
  Color? iconSecondaryColor;*/
  //Color? cardColor;

  Color? primaryColor; //rojo
  Color? primaryColorLight; // rojo claro
  Color? primaryColorDark; // rojo oscuro
  //Color? scaffoldBackground;
  Color? secondaryColor; // blanco
  Color? secondaryColorLight; // gris claro
  Color? secondaryColorDark; // gris oscuro
  Color? buttonNavColorBlue; // azul
  Color? buttonNavColorGreen; // verde
  Color? buttonNavColorOrange; // morado
  Color? blackColor; // negro
  List<Color> listNavColor =[]; // negro

  AppStore() {
    primaryColor = Colors.red;
    primaryColorLight = Color.fromARGB(255, 240, 108, 99);
    primaryColorDark = const Color.fromARGB(255, 114, 22, 15);

    secondaryColor = Colors.white;
    secondaryColorLight = Color.fromARGB(255, 199, 197, 197);
    secondaryColorDark = Color.fromARGB(255, 63, 62, 62);
    
    blackColor = Colors.black;

    listNavColor = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
    ];

    /* textPrimaryColor = Color(0xFF212121);
    iconColorPrimaryDark = Color(0xFF212121);
    scaffoldBackground = Color.fromARGB(255, 245, 247, 235);
    backgroundColor = Colors.black;
    backgroundSecondaryColor = Color(0xFF131d25);
    appColorPrimaryLightColor = Color(0xFFF9FAFF);
    textSecondaryColor = Color(0xFF5A5C5E);
    appBarColor = Color.fromARGB(255, 223, 220, 220);
    chipColor = const Color.fromARGB(255, 175, 15, 15);
    chipPrimaryColor = Color.fromARGB(255, 7, 120, 165);
    iconColor = Color(0xFF212121);
    iconSecondaryColor = Color(0xFFA8ABAD);
    //cardColor = Color(0xFF191D36);*/
    //cardColor = Color.fromARGB(255, 82, 33, 33);
  }
}
