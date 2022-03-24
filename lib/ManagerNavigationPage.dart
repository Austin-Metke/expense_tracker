import 'package:expense_tracker/ExpensesOverviewPage.dart';
import 'package:expense_tracker/MyExpensesPage.dart';
import 'package:expense_tracker/SettingsPage.dart';
import 'package:expense_tracker/UploadReceiptPage.dart';
import 'package:flutter/material.dart';
import 'ViewUsersPage.dart';
import 'Global.dart';
import 'ViewReceiptsPage.dart';

class ManagerNavigationPage extends StatefulWidget {
  const ManagerNavigationPage({Key? key,}) : super(key: key);

  @override
  _ManagerNavigationPageState createState() => _ManagerNavigationPageState();
}

class _ManagerNavigationPageState extends State<ManagerNavigationPage> {
  int _selectedIndex = 0;

  void _onBarTap(int index) => setState(() => _selectedIndex = index);

  static const List<Widget> _managerPages = <Widget>[
    MyExpensesPage(),
    ViewUploadedReceiptsPage(),
    ViewUserPage(),
    ExpensesOverviewPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "My Expenses",
              backgroundColor: Global.colorBlue,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pages),
              label: "My Receipts",
              backgroundColor: Global.colorBlue,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts),
              label: "Manage Users",
              backgroundColor: Global.colorBlue,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.attach_money_outlined,
              ),
              label: "Expenses",
              backgroundColor: Global.colorBlue,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
              backgroundColor: Global.colorBlue,
            ),
          ],

          onTap: (value) => _onBarTap(value),
          currentIndex: _selectedIndex,
          backgroundColor: Global.colorBlue,

          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
        ),
        resizeToAvoidBottomInset: false,
        body: IndexedStack(
          index: _selectedIndex,
          children: _managerPages
        ));
  }

}
