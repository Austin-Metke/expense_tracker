import 'package:expense_tracker/UploadReceiptPage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_platform_interface/src/id_token_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ViewUsersPage.dart';
import 'Global.dart';
import 'User.dart';
import "dart:convert";

import 'ViewReceiptsPage.dart';

class UserFunctionsPage extends StatefulWidget {
  const UserFunctionsPage({Key? key}) : super(key: key);

  @override
  _UserFunctionsPageState createState() => _UserFunctionsPageState();
}

class _UserFunctionsPageState extends State<UserFunctionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              style: Global.defaultButtonStyle,
              child: const Text("Upload receipt"),
              onPressed: () => _viewReceiptPage(),
            ),
            TextButton(
              style: Global.defaultButtonStyle,
              child: const Text("View and edit uploaded receipts"),
              onPressed: () => _viewUploadedReceiptsPage(),
            ),
            FutureBuilder(
              future: _isManager(),
              builder: ((context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  //If user is manager, show display employee receipts button
                  return _viewEmployeeReceiptsButton();
                } else if (snapshot.hasData && snapshot.data == false) {
                  //If user is not manager, display empty container
                  return Container();
                }

                //If snapshot is neither true or false, display empty container
                return Container();
              }),
            ),
            FutureBuilder(
              future: _isManager(),
              builder: ((context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  //If user is manager, display CRUD user button
                  return _crudButton();
                } else if (snapshot.hasData && snapshot.data == false) {
                  //If user is not manager, display empty container
                  print("SNAPSHOT DATA: ${snapshot.data}");
                  return Container();
                }

                //If user is neither manager or employee, display empty container
                return Container();
              }),
            ),
         //   testFunctionButton(),
          ],
        ),
      ),
    );
  }

  Widget testFunctionButton() => TextButton(
      style: Global.defaultButtonStyle,
      onPressed: ()  =>  _testFunction(),
      child: const Text("Test function"));

  Widget _crudButton() => TextButton(
        style: Global.defaultButtonStyle,
        child: const Text("Manage users"),
        onPressed: () async => await _viewUserEditPage(),
      );

  Widget _viewEmployeeReceiptsButton() => TextButton(
        style: Global.defaultButtonStyle,
        child: const Text("View all employee receipts"),
        onPressed: () => null,
      );

  _viewReceiptPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ReceiptUploadPage()));
  }

  _viewUserEditPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ViewUserPage()));
  }

  _viewUploadedReceiptsPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ViewUploadedReceiptsPage()));
  }

  Future<bool> _isManager() async {
    var isManager;

    await Global.auth.currentUser?.getIdTokenResult(true).then(
        (value) => {isManager = value.claims!['isManager'], print(isManager)});

    return isManager;
  }

  Future<void> _testFunction() async {
    HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-west2')
        .httpsCallable('getTotal');

    final resp = await callable.call(<String, dynamic> {
      'jwt': await Global.auth.currentUser!.getIdToken(),
    });

    print(resp.data);


  }
}
