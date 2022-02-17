import 'package:expense_tracker/ReceiptPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Global.dart';

class ManagerFunctionsPage extends StatefulWidget {
  const ManagerFunctionsPage({Key? key}) : super(key: key);

  @override
  _ManagerFunctionsPageState createState() => _ManagerFunctionsPageState();
}

class _ManagerFunctionsPageState extends State<ManagerFunctionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: Center(


        child: Column(

          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[


            Padding(
            padding: const EdgeInsets.all(20),
            child: TextButton(
              style: Global.defaultButtonStyle,
              child: Text("Upload receipt"),
              onPressed: () => _viewReceiptPage(),
            ),
            ),

            TextButton(
              style: Global.defaultButtonStyle,

              child: Text("View all receipts"),

              onPressed: () => null,

            ),

            TextButton(

              style: Global.defaultButtonStyle,
              child: Text("View own receipts"),

              onPressed: () => null,

            ),

            TextButton(

              style: Global.defaultButtonStyle,

              child: const Text("View, Edit, & Delete Users"),
              onPressed: () => _viewUserEditPage(),
            ),




          ],

        ),

      ),
    );


  }

  _viewReceiptPage() {

    Navigator.push( context,MaterialPageRoute(builder: (context) => const ReceiptRoute()) );
  }

  _viewUserEditPage() {



  }
}


