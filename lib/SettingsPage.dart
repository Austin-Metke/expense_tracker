import 'package:flutter/material.dart';

import 'Global.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final String? _userName = Global.auth.currentUser!.displayName;
  final String? _phoneNumber = Global.auth.currentUser!.phoneNumber;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Global.colorBlue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                enabled: false,
                readOnly: true,
                initialValue: _userName,
                decoration: const InputDecoration(
                  labelText: "Username",
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: TextFormField(
                readOnly: true,
                enabled: false,
                initialValue: _phoneNumber,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                ),
              ),
            ),

            DropdownButton<int>(items: const [
              DropdownMenuItem<int>(
                value: 0,
                child: Text("English"),
              ),

              DropdownMenuItem<int>(
                value: 1,
                child: Text("Spanish"),
              ),

            ], onChanged: (value) => _switchLanguage(value),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
            child: TextButton(
              onPressed: _logOut,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout),
                  Text("Logout",),
                ],
              ),
              style: Global.defaultButtonStyle,
            ),
            )
          ],
        ),
      ),
    );
  }

  void _logOut() async {
    await Global.auth.signOut();
  }

  _switchLanguage(int? value) {


  }
}
