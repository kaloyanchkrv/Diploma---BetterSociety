import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar header({bool isAppTitle = false, String titleText = ""}) {
  return AppBar(
    title: Text(
      isAppTitle ? "Better Society" : titleText,
      style: GoogleFonts.signika(
        color: Colors.white,
        fontSize: isAppTitle ? 40.0 : 30.0,
      ),
    ),
    centerTitle: true,
    backgroundColor: Colors.greenAccent,
  );
}
