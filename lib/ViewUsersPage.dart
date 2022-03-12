import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:expense_tracker/Global.dart';
import 'package:expense_tracker/addUserPage.dart';
import 'package:expense_tracker/EditUserPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class ViewUserPage extends StatefulWidget {
  const ViewUserPage({Key? key}) : super(key: key);

  @override
  _ViewUserPageState createState() => _ViewUserPageState();
}

class _ViewUserPageState extends State<ViewUserPage> {
  final _userStream =
      FirebaseFirestore.instance.collection('users').snapshots();
  late int selected;

  late TapDownDetails _tapDownDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("All Employees"),
          actions: [
            PopupMenuButton<int>(
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      children: const [
                        Icon(Icons.person_add_alt, color: Colors.black),
                        Text("Add user"),
                      ],
                    ),
                  ),
                ];
              },
              onSelected: (value) => {
                if (value == 0) {_showAddUserPage()}
              },
            ),
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

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return Column(children: [
                  InkWell(
                      onTap: () async => {
                            selected = (await showMenu<int>(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                    0,
                                    _tapDownDetails.globalPosition.dy,
                                    _tapDownDetails.globalPosition.dx,
                                    0),
                                items: [
                                  PopupMenuItem<int>(
                                    value: 0,
                                    child: GestureDetector(
                                      child: const Text("Edit user"),
                                    ),
                                  ),
                                  const PopupMenuItem<int>(
                                    value: 1,
                                    child: Text("Delete user"),
                                  ),
                                ]))!,
                            if (selected == 0)
                              {_showEditUserPage(data)}
                            else if (selected == 1)
                              {_deleteUser(data['email'])}
                          },
                      onTapDown: (tapDownDetails) =>
                          _tapDownDetails = tapDownDetails,
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        color: Colors.white10,
                        child: Row(children: <Widget>[
                          const Icon(Icons.person_outline),
                          data['name'] != Global.auth.currentUser!.displayName
                              ? Text(
                                  "User: ${data['name']}, Manager: ${data['isManager']}")
                              : Text(
                                  "User: ${data['name']} (you), Manager: ${data['isManager']}"),
                        ]),
                      )),
                ]);
              }).toList(),
            );
          },
        ));
  }

  _showEditUserPage(Map<String, dynamic> data) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => EditUserPage(userdata: data)));
  }

  Future<void> _deleteUser(String email) async {
    _loadingToast();

    final functions = FirebaseFunctions.instanceFor(region: 'us-west2');
    HttpsCallable callable = functions.httpsCallable('deleteUser');
    final resp = await callable.call(<String, dynamic>{
      'email': email,
      'jwt': await Global.auth.currentUser?.getIdToken(),
    });

    print(resp.data);

    switch (resp.data) {
      case 'can\'t delete self':
        _deleteSelfToast();
        break;

      case 'success':
        _successToast();
        break;

      default:
    }
  }

  _loadingToast() {
    showToast('Deleting user...',
        position: ToastPosition.bottom,
        backgroundColor: Colors.grey,
        radius: 10.0,
        textStyle: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.035,
            color: Colors.white),
        dismissOtherToast: true,
        textAlign: TextAlign.center,
        duration: const Duration(seconds: Duration.secondsPerMinute));
  }

  _deleteSelfToast() {
    showToast(
      'You can\'t delete yourself!',
      position: ToastPosition.bottom,
      backgroundColor: Colors.red,
      radius: 10.0,
      textStyle: TextStyle(
        fontSize: MediaQuery.of(context).size.width * 0.035,
        color: Colors.white,
      ),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

  _successToast() {
    showToast(
      'User successfully created!',
      position: ToastPosition.bottom,
      backgroundColor: Colors.greenAccent.shade400,
      radius: 10.0,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.035,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

  _showAddUserPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AddUserPage()));
  }
}