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
  final _userStream =
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    test();
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("All Employees"),
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
        body: StreamBuilder<QuerySnapshot>(
          stream: _userStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return const Text('Something went wrong');
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return Column(children: [
                  InkWell(
                      child: Container(
                    margin: EdgeInsets.all(10),
                    color: Colors.white10,
                    child: Text(
                        "User: ${data['name']}, Manager: ${data['isManager']}"),
                  )),
                ]);
              }).toList(),
            );
          },
        ));
  }

  test() async {}

  _showEditUserPage() {}
}

_showDelteUserPage() {}

_showAddUserPage() {}

Future<void> _createUser(User user) async {
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('makeUser');
  final resp = await callable.call(await user.toJson());
}
