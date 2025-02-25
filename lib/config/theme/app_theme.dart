import 'package:flutter/material.dart';

class AppTheme {

  ThemeData getTheme() {
    const seedColor = Colors.green;
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: seedColor,
      // listTileTheme: const ListTileThemeData(
      //   iconColor: seedColor
      // )
      appBarTheme: AppBarTheme(
        backgroundColor: seedColor,
        titleTextStyle: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold
        )
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(seedColor),
          textStyle: MaterialStateProperty.all(
            const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )
          )
        )
      ),
    );
  }

}