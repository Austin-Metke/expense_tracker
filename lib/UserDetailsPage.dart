import 'package:expense_tracker/EmployeeUploadedReceiptsPage.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import 'Global.dart';

class UserDetailsPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserDetailsPage({Key? key, required this.userData}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  late String _name;
  late double? _total;
  late int? _receiptsUploaded;
  late String? _phoneNumber;

  @override
  void initState() {
    _name = widget.userData['name'];
    _total = widget.userData['total'];
    _receiptsUploaded = widget.userData['uploadedReceipts'];
    _phoneNumber = widget.userData['phoneNumber'];
  }

  @override
  Widget build(BuildContext context) {
    print("TEST");
    return OKToast(
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("Details for $_name"),
              actions: [
                PopupMenuButton<int>(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem<int>(
                        value: 0,
                        child: Text("View receipts"),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    switch(value) {
                      case 0:
                        _viewUserReceiptsPage(userPhoneNumber: _phoneNumber, userName: _name);
                        break;

                    }
                  },
                ),

              ],
              backgroundColor: Global.colorBlue,
            ),
            body: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text("Name: $_name"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Total for the week: "),
                        Text("\$ ${(_total ?? "\$0.00")}", style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                      ],
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Receipts for the week: "),
                        Text("${(_receiptsUploaded == 0 || _receiptsUploaded == null) ? "none" : _receiptsUploaded}", style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                      ],
                    )
                  ),
                ],
              ),
            )));
  }

  void _viewUserReceiptsPage({required String? userPhoneNumber, required String? userName}) {

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => EmployeeUploadedReceiptsPage(phoneNumber: userPhoneNumber, name: userName,)));

  }
}
