import 'package:expense_tracker/ExpensesOverviewPage.dart';
import 'package:expense_tracker/UploadReceiptPage.dart';
import 'package:flutter/material.dart';
import 'ViewUsersPage.dart';
import 'Global.dart';
import 'ViewReceiptsPage.dart';

class UserFunctionsPage extends StatefulWidget {
  const UserFunctionsPage({Key? key}) : super(key: key);

  @override
  _UserFunctionsPageState createState() => _UserFunctionsPageState();
}

class _UserFunctionsPageState extends State<UserFunctionsPage> {

  int _selectedIndex = 0;

  void _onBarTap(int index) => setState(() => _selectedIndex = index);

  static const List<Widget> _pages = <Widget>[
    ViewUploadedReceiptsPage(),
    ViewUserPage(),
    ExpensesOverviewPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: Global.bottomNavigationBarItems,
        onTap: (value) => _onBarTap(value),
        currentIndex: _selectedIndex,
        backgroundColor: Global.colorBlue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
      ),

      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      )
      );
  }



  Future<bool> _isManager() async {
    var isManager;

    await Global.auth.currentUser?.getIdTokenResult(true).then(
        (value) => {isManager = value.claims!['isManager'], print(isManager)});

    return isManager;
  }

}
