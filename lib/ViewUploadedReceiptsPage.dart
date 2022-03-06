import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/Global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewUploadedReceiptsPage extends StatefulWidget {
  const ViewUploadedReceiptsPage({Key? key}) : super(key: key);

  @override
  _ViewUploadedReceiptsPageState createState() =>
      _ViewUploadedReceiptsPageState();
}

class _ViewUploadedReceiptsPageState extends State<ViewUploadedReceiptsPage> {
  final Stream<QuerySnapshot> _receiptStream = FirebaseFirestore.instance
      .collection('users/${Global.auth.currentUser!.uid}/receipts')
      .snapshots();
  final Stream<QuerySnapshot> _receiptStreamByTotal = FirebaseFirestore.instance
      .collection('users/${Global.auth.currentUser!.uid}/receipts')
      .orderBy('total', descending: true)
      .snapshots();

  final Stream<QuerySnapshot> _receiptStreamByDateDescending = FirebaseFirestore
      .instance
      .collection('users/${Global.auth.currentUser!.uid}/receipts')
      .orderBy('date', descending: true)
      .snapshots();

  final Stream<QuerySnapshot> _receiptStreamByDateAscending = FirebaseFirestore
      .instance
      .collection('users/${Global.auth.currentUser!.uid}/receipts')
      .orderBy('date', descending: false)
      .snapshots();

  bool _orderByTotal = false;
  bool _orderByDateDescending = false;
  bool _orderByDateAscending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Uploaded Receipts"),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: const Text("Add Receipt"),
                    onTap: () => null,
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: const Text("Edit Receipt"),
                    onTap: () => null,
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: const Text("Delete Receipt"),
                    onTap: () => null,
                  ),
                  PopupMenuItem<int>(
                    value: 3,
                    child: const Text("Sort by value"),
                    onTap: () => _sortByValue(),
                  ),
                  PopupMenuItem<int>(
                    value: 4,
                    child: const Text("Sort by newest"),
                    onTap: () => _sortByDateDescending(),
                  ),
                  PopupMenuItem<int>(
                    value: 5,
                    child: const Text("Sort by oldest"),
                    onTap: () => _sortByDateAscending(),
                  ),
                ];
              },
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _getStream(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text("Loading..."));
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;

                return InkWell(
                  onTap: () => print("asdf"),
                    child: Container(
                        margin: const EdgeInsets.all(10),
                        color: const Color.fromARGB(100, 121, 121, 121),
                        child: Column(
                          children: [
                            Image.memory(
                              base64Decode(data['image']),
                            ),

                            Text(
                              "Total: ${NumberFormat.simpleCurrency().format(
                                  data['total'])}",
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),

                            //If data['comment'] is null, display Text("none)" to prevent build() from breaking

                            data['comment'] == null
                                ? const Text("Comment: none",
                                style: TextStyle(
                                  fontSize: 18,
                                ))
                                : Text(
                              "Comment: ${data['comment'] ?? "none"}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            //If a date isn't entered as an int (somehow), display a Text() to prevent build() from breaking
                            data['date'] is int
                                ? Text(
                                "Uploaded on: ${DateFormat(
                                    DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY)
                                    .format(DateTime.fromMicrosecondsSinceEpoch(
                                    data['date']))}")
                                : const Text("Unknown"),
                          ],
                        )),);
              }).toList(),
            );
          },
        ));
  }

  _getStream() {
    if (_orderByTotal && _orderByDateAscending && _orderByDateDescending) {
      return _receiptStream;
    } else if (_orderByTotal) {
      return _receiptStreamByTotal;
    } else if (_orderByDateDescending) {
      return _receiptStreamByDateDescending;
    } else if (_orderByDateAscending) {
      return _receiptStreamByDateAscending;
    }

    return _receiptStream;
  }

  _sortByValue() {
    _orderByDateAscending = false;
    _orderByDateDescending = false;
    setState(() => _orderByTotal = true);
  }

  _sortByDateAscending() {
    _orderByDateDescending = false;
    _orderByTotal = false;
    setState(() => _orderByDateAscending = true);
  }

  _sortByDateDescending() {
    _orderByDateDescending = false;
    _orderByTotal = false;
    setState(() => _orderByDateDescending = true);
  }
}
