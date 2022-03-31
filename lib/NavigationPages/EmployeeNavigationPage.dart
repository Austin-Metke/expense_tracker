import 'package:flutter/material.dart';
import '../Global.dart';
import '../ExpensePages/MyExpensesPage.dart';
import '../SettingsPage.dart';
import '../ReceiptPages/ViewReceiptsPage.dart';

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

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    void _onBarTap(int index) => setState(() => _selectedIndex = index);

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        onTap: _onBarTap,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pages),
            label: "My Expenses",
            backgroundColor: Global.colorBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "My receipts",
            backgroundColor: Global.colorBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
            ),
            label: "Settings",
            backgroundColor: Global.colorBlue,
          ),
        ],
      ),
      body: IndexedStack(
        children: _employeePages,
        index: _selectedIndex,
        alignment: Alignment.center,
      ),
    );
  }
}
