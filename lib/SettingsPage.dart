import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Global.dart';
import 'NavigationPages/LoginPage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Global.colorBlue,
      ),
      body: FutureBuilder(
        future: _getUserDoc(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none) {
            return const Center(child: Text("Loading"));
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(child: Text("An error has occurred!"));
          } else if (snapshot.hasData) {
            String? _userName = snapshot.data!['name'];
            String? _phoneNumber = snapshot.data!['phoneNumber'];
            return Center(
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
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: TextFormField(
                      readOnly: true,
                      enabled: false,
                      initialValue: Global.phoneInputFormatter
                          .applyMask(_phoneNumber!)
                          .text,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                      ),
                    ),
                  ),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: TextButton(
                      onPressed: _logOut,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout),
                          Text(
                            "Logout",
                          ),
                        ],
                      ),
                      style: Global.defaultButtonStyle,
                    ),
                  )
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  Future<DocumentSnapshot> _getUserDoc() async {
    final userDoc = await FirebaseFirestore.instance
        .doc('users/${Global.auth.currentUser!.uid}')
        .get();
    return userDoc;
  }

  void _logOut() async {
    await Global.auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const ExpenseTracker()));

  }

  _switchLanguage(int? value) {}
}
