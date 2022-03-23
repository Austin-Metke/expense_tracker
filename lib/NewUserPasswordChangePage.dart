import 'package:flutter/material.dart';

import 'Global.dart';

class NewUserPasswordChangePage extends StatefulWidget {
  const NewUserPasswordChangePage({Key? key}) : super(key: key);

  @override
  _NewUserPasswordChangePageState createState() => _NewUserPasswordChangePageState();
}

class _NewUserPasswordChangePageState extends State<NewUserPasswordChangePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text("Change your password"),
        centerTitle: true,
        backgroundColor: Global.colorBlue,
      ),

    );
  }
}
