import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.deepPurple,
    fontFamily: GoogleFonts.notoSansTifinagh().fontFamily,
    textTheme: GoogleFonts.narnoorTextTheme(),
    appBarTheme: const AppBarTheme(
      color: Colors.deepPurple,
      centerTitle: false,
      elevation: 4,
      titleTextStyle: TextStyle(
        color: Colors.white, 
        fontSize: 20, 
        fontWeight: FontWeight.bold, 
      ),
      iconTheme: IconThemeData(
        color: Colors.white, 
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.deepPurple,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    //FIXME:
    // elevatedButtonTheme: ElevatedButtonThemeData(
    //   style: ElevatedButton.styleFrom(
    //     backgroundColor: Colors.deepPurple,
    //     foregroundColor: Colors.white,
    //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(8),
    //     ),
    //   ),
    // ),
  );

}
