import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Global.dart';
import '../NavigationPages/EmployeeNavigationPage.dart';
import '../NavigationPages/ManagerNavigationPage.dart';

class NewUserPasswordChangePage extends StatefulWidget {
  final bool isManager;

  const NewUserPasswordChangePage({Key? key, required this.isManager})
      : super(key: key);

  @override
  _NewUserPasswordChangePageState createState() =>
      _NewUserPasswordChangePageState();
}

class _NewUserPasswordChangePageState extends State<NewUserPasswordChangePage> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  String? _password;
  bool? _isManager;

  @override
  void initState() {
    super.initState();
    _isManager = widget.isManager;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Change your password"),
          centerTitle: true,
          backgroundColor: Global.colorBlue,
        ),
        body: Form(
          key: _key,
          child: Column(
            children: [
              //Password
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(Global.defaultRadius)),
                    ),
                    prefixIcon: Icon(Icons.lock),
                    hintText: "Password",
                  ),
                  validator: (value) => _passwordValidator(value),
                  onChanged: (value) => setState(() => _password = value),
                ),
              ),

              //Confirm password
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Confirm password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(Global.defaultRadius)),
                    ),
                    prefixIcon: Icon(Icons.lock),
                    hintText: "Confirm Password",
                  ),
                  validator: (value) => _confirmPasswordValidator(value),
                ),
              ),

              TextButton(
                  onPressed: _changePassword,
                  child: const Text("Change password"),
                  style: Global.defaultButtonStyle),
            ],
          ),
        ));
  }

  String? _passwordValidator(String? value) {
    if (value!.isEmpty) {
      return "Please enter a password!";
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value!.isEmpty) {
      return "Please enter a password";
    } else if (value != _password) {
      return "Passwords do not match!";
    }

    return null;
  }

  void _changePassword() async {
    Global.auth.currentUser!.updatePassword(_password!);

    try {
      await FirebaseFirestore.instance
          .doc('isFirstSignIn/${Global.auth.currentUser!.uid}')
          .update({
        "isFirstSignIn": false,
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => (_isManager!)
                  ? const ManagerNavigationPage()
                  : const EmployeeNavigationPage()));
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }
}
