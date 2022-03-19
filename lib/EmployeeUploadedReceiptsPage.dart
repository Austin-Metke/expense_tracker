import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'Global.dart';

class EmployeeUploadedReceiptsPage extends StatefulWidget {
  final String? phoneNumber;
  final String? name;

  const EmployeeUploadedReceiptsPage(
      {Key? key, required this.phoneNumber, required this.name})
      : super(key: key);

  @override
  _EmployeeUploadedReceiptsPageState createState() =>
      _EmployeeUploadedReceiptsPageState();
}

class _EmployeeUploadedReceiptsPageState
    extends State<EmployeeUploadedReceiptsPage> {
  late String? _phoneNumber;
  late String? _name;

  @override
  initState() {
    super.initState();
    _phoneNumber = widget.phoneNumber;
    _name = widget.name;
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("$_name receipts"),
          centerTitle: true,
          backgroundColor: Global.colorBlue,
        ),
        body: StreamBuilder<List<Map<dynamic, dynamic>>>(
            builder: (BuildContext context,
                AsyncSnapshot<List<Map<dynamic, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text("Loading"));
              } else if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  print(snapshot.error.toString());

                  return const Center(
                      child: Text("An unknown error has occurred"));
                } else if (snapshot.hasData) {

                  return ListView(

                    children: [

                    ]

                  );

                }
              }
              return Text("some error occcured, probably");
            },
            stream: Stream.fromFuture(getUserReceipts())));
  }

  Future<List<Map<dynamic, dynamic>>> getUserReceipts() async {
    HttpsCallable callable = FirebaseFunctions.instanceFor(region: "us-west2")
        .httpsCallable('getUserReceipts');

    final resp = await callable.call(<String, dynamic>{
      'email': "$_phoneNumber@fakeemail.com",
    });

    final data = resp.data as List;

    List<Map<String, dynamic>> receiptList = [];

    for(var e in data) {

      receiptList.add(jsonDecode(e.toString()));
    }

    return receiptList;

/*    data.forEach((element) {

      var test = element.toString().split("stringValue");

    });*/
  }
}
