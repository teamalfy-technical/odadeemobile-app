import 'package:flutter/material.dart';

import '../../constants.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    fontFamily: "DMSans",
    appBarTheme: appBarTheme(),
    textTheme: textTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

TextTheme textTheme() {
  return const TextTheme(
    bodySmall: TextStyle(color: bodyText1),
    bodyMedium: TextStyle(color: bodyText1),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    color: odaPrimary,
    elevation: 0,
    /* brightness: Brightness.dark,
    iconTheme: IconThemeData(color: bodyText1),
      textTheme: TextTheme(
      headline6: TextStyle(color: bodyText1, fontSize: 12
      )
  )*/
  );
}
