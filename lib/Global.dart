import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

@immutable
abstract class Global {
  static const Color colorBlue = Color(0xff5d5fef); //Default color used throughout most of the app, '0xff' must be appended to the hex value of the color for dart to use it
  static const phoneNumberLength = 10;
  static const minPasswordLength = 6;
  static const characterLimit = 300; //Character limit of a comment, used in UploadReceiptPage.dart and EditReceiptPage.dart
  static MaskedInputFormatter phoneInputFormatter = MaskedInputFormatter('000-000-0000'); //Formatter used for phone numbers
  static const PosInputFormatter moneyInputFormatter = PosInputFormatter( //Formatter used for currency
      mantissaLength: 2, thousandsSeparator: ThousandsPosSeparator.comma);
  static const double defaultRadius = 10; //The default radius of all TextButtons(), TextFormFields(), and Toasts()
  static const imageCompression = 50; //Compression for uploaded images, goes from 0 to 100, used in UploadReceiptPage.dart and EditReceiptPage.dart
  static const imageQuality = 30; //Quality of uploaded images, goes from 0 to 100, used in UploadReceiptPage.dart and EditReceiptPage.dart
  static const SizedBox defaultIconSpacing = SizedBox(width: 5,); //Spacing used between Icons() and Text()
  static final ButtonStyle defaultButtonStyle = TextButton.styleFrom( //The default button style used across the entire app
    shape: const StadiumBorder(),
    maximumSize: Size.infinite,
    backgroundColor: Global.colorBlue,
    primary: Colors.white,
  );

  static final FirebaseAuth auth = FirebaseAuth.instance;
}
