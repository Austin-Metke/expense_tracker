import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/Global.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../CustomWidgets/ReceiptWidget.dart';

class EmployeeUploadedReceiptsPage extends StatefulWidget {
  final String? name;
  final String? userID;

  const EmployeeUploadedReceiptsPage(
      {Key? key, required this.name, required this.userID})
      : super(key: key);

  @override
  _EmployeeUploadedReceiptsPageState createState() =>
      _EmployeeUploadedReceiptsPageState();
}

class _EmployeeUploadedReceiptsPageState
    extends State<EmployeeUploadedReceiptsPage> {
  late String? _name;
  late Stream<QuerySnapshot> _receiptStream;
  late bool isLoading;

  late String? _userID;

  @override
  initState() {
    isLoading = true;
    super.initState();
    _userID = widget.userID;
    _name = widget.name;
    _receiptStream = _getReceiptStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$_name receipts"),
        centerTitle: true,
        backgroundColor: Global.colorBlue,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem<int>(
                  value: 0,
                  child: const Text("Sort by value"),
                  onTap: () => _sortByValue(),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: const Text("Sort by newest"),
                  onTap: () => _sortByDateDescending(),
                ),
                PopupMenuItem<int>(
                  value: 2,
                  child: const Text("Sort by oldest"),
                  onTap: () => _sortByDateAscending(),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _receiptStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text("Loading..."));
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return RefreshIndicator(
                onRefresh: _onRefresh,
                child: const Center(
                    child: Text(
                        "An unknown error has occurred, please refresh and try again")));
          } else {
            if (snapshot.data!.size == 0) {
              return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: const Center(
                      child: Text("No receipts have been uploaded")));
            }

            return RefreshIndicator(
                child: _getDocumentListView(snapshot), onRefresh: _onRefresh);
          }
        },
      ),
    );
  }

  Widget _getDocumentListView(AsyncSnapshot<QuerySnapshot> snapshot) {
    return ListView(
      children: snapshot.data!.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> receiptData =
            document.data()! as Map<String, dynamic>;
        var total = receiptData['total'] / 100;
        var comment = receiptData['comment'];
        var date = receiptData['date'];
        var image = base64Decode(receiptData['image']);
        var expenseType = receiptData['expenseType'];
        return InkWell(
            child: Container(
          padding: const EdgeInsets.all(10),
          child: ReceiptWidget(
            total: total,
            image: image,
            expenseType: expenseType,
            date: date,
            comment: comment,
          ),
        ));
      }).toList(),
    );
  }

  _sortByValue() async {
    setState(() => _receiptStream = _getReceiptStreamByValue());
  }

  _sortByDateAscending() async {
    setState(() => _receiptStream = _getReceiptStreamByDateAscending());
  }

  _sortByDateDescending() async {
    setState(() => _receiptStream = _getReceiptStreamByDateDescending());
  }

  Stream<QuerySnapshot> _getReceiptStream() async* {
    yield* FirebaseFirestore.instance
        .collection("users/$_userID/receipts")
        .snapshots();
  }

  Stream<QuerySnapshot> _getReceiptStreamByValue() async* {
    yield* FirebaseFirestore.instance
        .collection("users/$_userID/receipts")
        .orderBy('total', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> _getReceiptStreamByDateAscending() async* {
    yield* FirebaseFirestore.instance
        .collection("users/$_userID/receipts")
        .orderBy('date', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> _getReceiptStreamByDateDescending() async* {
    yield* FirebaseFirestore.instance
        .collection("users/$_userID/receipts")
        .orderBy('date', descending: false)
        .snapshots();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }
}
