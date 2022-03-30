import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/Global.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ViewArchivedReceiptsPage extends StatefulWidget {
  final DateTime selectedDay;
  final userID;
  const ViewArchivedReceiptsPage({Key? key, required this.selectedDay, required this.userID}) : super(key: key);

  @override
  _ViewArchivedReceiptsPageState createState() => _ViewArchivedReceiptsPageState();
}


class _ViewArchivedReceiptsPageState extends State<ViewArchivedReceiptsPage> {


  late final DateTime? _selectedDay;
  late final String? _userID;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _selectedDay = widget.selectedDay;
    _userID = widget.userID;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Archived Receipts"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getArchivedReceipts(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text("Loading..."));
          } else if(snapshot.hasError) {
            print(snapshot.error);
            return const Center(child: Text("An error occurred!"));
          } else {

            return RefreshIndicator(child: _getDocumentListView(snapshot), onRefresh: _onRefresh);

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

          return InkWell(
            child: Container(
                margin: const EdgeInsets.all(10),
                color: const Color.fromARGB(100, 121, 121, 121),
                child: Column(children: [
                  Image.memory(image),
                  Text(
                    "Total: ${NumberFormat.simpleCurrency().format(total)}",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Text(
                      "Comment: ${(comment != null || comment == ""
                          ? comment
                          : "none")}",
                      style: const TextStyle(
                        fontSize: 18,
                      )),
                  //Ternary operation to ensure build() doesn't break on the offchance an upload date isn't stored
                  Text(
                      "Uploaded on: ${(date is int ? "${_getDateUploaded(
                          date)} at ${_getTimeUploaded(date)}" : "Unknown")}")
                ])),
          );
        }).toList());
  }

  _getDateUploaded(int time) {
    return DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY)
        .format(DateTime.fromMicrosecondsSinceEpoch(time));
  }

  _getTimeUploaded(int time) {
    return DateFormat(DateFormat.HOUR_MINUTE)
        .format(DateTime.fromMicrosecondsSinceEpoch(time));
  }



  Stream<QuerySnapshot> _getArchivedReceipts() async* {

    yield* FirebaseFirestore.instance.collection('archivedReceipts/$_userID/receipts').where('date', isEqualTo: _selectedDay!.microsecondsSinceEpoch).snapshots();

  }



  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
