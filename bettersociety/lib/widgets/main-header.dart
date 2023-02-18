import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar Header(
    {bool isAppTitle = false,
    String titleText = "",
    removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? "Better Society" : titleText,
      style: GoogleFonts.signika(
        color: Colors.white,
        fontSize: isAppTitle ? 30.0 : 30.0,
      ),
    ),
    centerTitle: true,
    backgroundColor: Colors.greenAccent,
  );
}
