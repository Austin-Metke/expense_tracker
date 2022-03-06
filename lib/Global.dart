import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class Global {

  static const Color colorBlue = Color(0xff5d5fef);

  static ButtonStyle defaultButtonStyle =  TextButton.styleFrom(
  shape: const StadiumBorder(),
  maximumSize: Size.infinite,
  backgroundColor: Global.colorBlue,
  primary: Colors.white,
  );
  static final FirebaseAuth auth = FirebaseAuth.instance;


}