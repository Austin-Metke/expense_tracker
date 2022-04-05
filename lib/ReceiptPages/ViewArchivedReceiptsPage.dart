import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/CustomWidgets/ReceiptWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Global.dart';

class ViewArchivedReceiptsPage extends StatefulWidget {
  final DateTime selectedDay;
  final String? userID;
  final String? name;

  const ViewArchivedReceiptsPage(
      {Key? key,
      required this.selectedDay,
      required this.userID,
      required this.name})
      : super(key: key);

  @override
  _ViewArchivedReceiptsPageState createState() =>
      _ViewArchivedReceiptsPageState();
}

class _ViewArchivedReceiptsPageState extends State<ViewArchivedReceiptsPage> {
  late final DateTime? _selectedDay;
  late final String? _userID;
  late final String? _name;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay;
    _userID = widget.userID;
    _name = widget.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            "$_name Receipts For Week Of ${DateFormat(DateFormat.ABBR_MONTH_DAY).format(_selectedDay!)}"),
        titleSpacing: 0,
        backgroundColor: Global.colorBlue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getArchivedReceipts(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text("Loading..."));
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(child: Text("An error occurred!"));
          } else {
            return RefreshIndicator(
                child: _getDocumentListView(snapshot), onRefresh: _onRefresh);
          }
        },
      ),
    );
  }

  _getDocumentListView(AsyncSnapshot<QuerySnapshot> snapshot) {
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
          expenseType: expenseType,
          date: date,
          image: image,
          comment: comment,
        ),
        ));
    }).toList());
  }

  Stream<QuerySnapshot> _getArchivedReceipts() async* {
    
    DateTime firstDayOfWeek = _selectedDay!;
    DateTime lastDayOfWeek = _selectedDay!;

    /*
    This implementation is really bad, but it works. To query all the receipts for the week of the given day,
    we take the selected day, and continue adding/subtracting 1 day until we reach the beginning and end of the week.
    We then pass in the beginning and end of the week to make the query.
     */

    while (firstDayOfWeek.weekday != DateTime.sunday) {
      firstDayOfWeek = firstDayOfWeek.subtract(const Duration(days: 1));
    }

    while (lastDayOfWeek.weekday != DateTime.saturday) {
      lastDayOfWeek = lastDayOfWeek.add(const Duration(days: 1));
    }

    yield* FirebaseFirestore.instance
        .collection('archivedReceipts/$_userID/receipts')
        .where('date',
            isGreaterThanOrEqualTo: firstDayOfWeek.microsecondsSinceEpoch,
            isLessThanOrEqualTo: lastDayOfWeek.microsecondsSinceEpoch)
        .snapshots();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
