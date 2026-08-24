import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme =
      ThemeData(
                  useMaterial3: true,
                  colorSchemeSeed: Colors.indigo,
                  scaffoldBackgroundColor: const Color(0xFFF5F7FB),
                  appBarTheme:
                      const AppBarTheme(
                              centerTitle: false,
                            ),

                  cardTheme: 
                      const CardThemeData(
                                elevation: 1,
                                margin: EdgeInsets.zero,
                              ),

                  inputDecorationTheme:
                      const InputDecorationTheme(
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                );
}