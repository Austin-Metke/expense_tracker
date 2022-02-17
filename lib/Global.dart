import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class Global {

  static Color colorBlue = const Color(0xff5d5fef);

  static ButtonStyle defaultButtonStyle = TextButton.styleFrom(
  shape: const StadiumBorder(),
  maximumSize: Size.infinite,
  backgroundColor: Global.colorBlue,
  primary: Colors.white,
  );
}