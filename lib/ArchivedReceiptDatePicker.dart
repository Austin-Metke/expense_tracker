import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/Global.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'ViewArchivedReceiptsPage.dart';

class ArchivedReceiptDatePickerPage extends StatefulWidget {
  final String? name;
  final String? userID;

  const ArchivedReceiptDatePickerPage(
      {Key? key, required this.name, required this.userID}) : super(key: key);

  @override
  _ArchivedReceiptDatePickerPageState createState() =>
      _ArchivedReceiptDatePickerPageState();
}

class _ArchivedReceiptDatePickerPageState
    extends State<ArchivedReceiptDatePickerPage> {

  late String? _name;
  late String? _userID;
  DateTime? _focusedDay;
  DateTime? _selectedDay;
  DateTime? _firstDay;
  DateTime? _lastDay;
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  @override void initState() {
    // TODO: implement initState
    super.initState();
    _name = widget.name;
    _userID = widget.userID;
    _setFirstDay();
    _setLastAndFocusedDay();
  }

  void _setFirstDay() async {
    final firstReceiptTimestamp = await _getFirstReceiptTimestamp();

    setState(() =>
    _firstDay = DateTime.fromMicrosecondsSinceEpoch(firstReceiptTimestamp));
  }

  void _setLastAndFocusedDay() async {
    final lastReceiptTimestamp = await _getLastReceiptTimestamp();

    setState(() {
      _lastDay = DateTime.fromMicrosecondsSinceEpoch(lastReceiptTimestamp);
      _focusedDay = DateTime.fromMicrosecondsSinceEpoch(lastReceiptTimestamp);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(" $_name Archived receipts"),
        backgroundColor: Global.colorBlue,
      ),

      body: (_firstDay != null && _lastDay != null && _focusedDay != null)
          ? TableCalendar(
        firstDay: _firstDay!,
        focusedDay: _focusedDay!,
        lastDay: _lastDay!,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _viewArchivedReceipts(selectedDay);
          }
        },

      )
          : const Center(child: Text("Loading...")),
    );
  }



  _viewArchivedReceipts(DateTime selectedDay) {

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ViewArchivedReceiptsPage(selectedDay: selectedDay, userID: _userID,)));

  }


  Future<int> _getFirstReceiptTimestamp() async {
    final archivedReceiptsSnapshot = await FirebaseFirestore.instance
        .collection('archivedReceipts/$_userID/receipts').orderBy(
        'date', descending: false).limit(1).get();

    return archivedReceiptsSnapshot.docs[0].get('date');
  }

  Future<int> _getLastReceiptTimestamp() async {
    final archivedReceiptsSnapshot = await FirebaseFirestore.instance
        .collection('archivedReceipts/$_userID/receipts').orderBy(
        'date', descending: true).limit(1).get();

    return archivedReceiptsSnapshot.docs[0].get('date');
  }

}
