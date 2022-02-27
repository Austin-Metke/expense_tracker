import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'User.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({Key? key}) : super(key: key);

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  var dbRef = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    test();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Test"),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                 PopupMenuItem<int>(
                  value: 0,
                  child: const Text("Add user"),
                  onTap: () => _showAddUserPage(),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: const Text("Edit user"),
                  onTap: () => _showEditUserPage(),
                ),
                PopupMenuItem<int>(
                  value: 2,
                  child: const Text("Delete user"),
                  onTap: () => _showDelteUserPage(),
                ),
              ];
            },
          )
        ],
      ),
      body: Center(
        child: Container(),
      ),
    );
  }

  test() async {

  }

  _showEditUserPage() {

  }
}

_showDelteUserPage() {

}

_showAddUserPage() {
}

Future<void> _createUser(User user) async {
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('makeUser');
  final resp = await callable.call(await user.toJson());
}