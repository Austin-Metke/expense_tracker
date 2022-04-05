import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

@immutable
abstract class Global {
  static const Color colorBlue = Color(0xff5d5fef);
  static const phoneNumberLength = 10;
  static MaskedInputFormatter phoneInputFormatter =
      MaskedInputFormatter('000-000-0000');
  static const PosInputFormatter moneyInputFormatter = PosInputFormatter(
      mantissaLength: 2, thousandsSeparator: ThousandsPosSeparator.comma);
  static const double defaultRadius = 10;
  static const imageCompression = 50;
  static const imageQuality = 30;
  static const SizedBox defaultIconSpacing = SizedBox(
    width: 5,
  );

  static final ButtonStyle defaultButtonStyle = TextButton.styleFrom(
    shape: const StadiumBorder(),
    maximumSize: Size.infinite,
    backgroundColor: Global.colorBlue,
    primary: Colors.white,
  );

  static final FirebaseAuth auth = FirebaseAuth.instance;
}
