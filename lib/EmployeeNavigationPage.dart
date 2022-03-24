import 'dart:ui';

import 'package:flutter/material.dart';

import 'MyExpensesPage.dart';
import 'SettingsPage.dart';
import 'ViewReceiptsPage.dart';

class EmployeeNavigationPage extends StatefulWidget {
  const EmployeeNavigationPage({Key? key}) : super(key: key);

  @override
  _EmployeeNavigationPageState createState() => _EmployeeNavigationPageState();
}

class _EmployeeNavigationPageState extends State<EmployeeNavigationPage> {
  static const List<Widget> _employeePages = <Widget>[
    MyExpensesPage(),
    ViewUploadedReceiptsPage(),
    SettingsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pages),
            label: "My Expenses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "My receipts",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
            ),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
