import 'package:expense_tracker/ViewReceiptsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import 'ExpensesOverviewPage.dart';
import 'ViewUsersPage.dart';

@immutable
abstract class Global {
  static const Color colorBlue = Color(0xff5d5fef);
  static const phoneNumberLength = 10;
  static MaskedInputFormatter phoneInputFormatter =
      MaskedInputFormatter('###-###-####');
  static PosInputFormatter moneyInputFormatter = const PosInputFormatter(
      mantissaLength: 2, thousandsSeparator: ThousandsPosSeparator.comma);
  static const double? defaultRadius = 10;
  static const imageCompression = 50;
  static const imageQuality = 30;
  static const SizedBox defaultIconSpacing = SizedBox(
    width: 5,
  );

  static const pages = <String, Widget>{
    "myReceipts": ViewUploadedReceiptsPage(),
    "manageUsers": ViewUserPage(),
    "expensesOverview": ExpensesOverviewPage(),
  };

  static ButtonStyle defaultButtonStyle = TextButton.styleFrom(
    shape: const StadiumBorder(),
    maximumSize: Size.infinite,
    backgroundColor: Global.colorBlue,
    primary: Colors.white,
  );

  static final FirebaseAuth auth = FirebaseAuth.instance;


  static const bottomNavigationBarItems = [
      BottomNavigationBarItem(icon: Icon(Icons.home),
        label: "My receipts",
      ),
      BottomNavigationBarItem(icon: Icon(Icons.person),
        label: "Manage users",
      ),
      BottomNavigationBarItem(icon: Icon(Icons.attach_money_outlined,),
        label: "Expenses overview",
      ),
    ];
  }
