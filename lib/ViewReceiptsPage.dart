import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/Global.dart';
import 'package:expense_tracker/UploadReceiptPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'EditReceiptPage.dart';

class ViewUploadedReceiptsPage extends StatefulWidget {
  const ViewUploadedReceiptsPage({Key? key}) : super(key: key);

  @override
  _ViewUploadedReceiptsPageState createState() =>
      _ViewUploadedReceiptsPageState();
}

class _ViewUploadedReceiptsPageState extends State<ViewUploadedReceiptsPage> {
  final dbRef = FirebaseFirestore.instance.collection('users');

   Stream<QuerySnapshot> _receiptStream = FirebaseFirestore.instance
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

  int? selectedValue;

  late TapDownDetails _tapDownDetails;

  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Global.colorBlue,
              centerTitle: true,
              title: const Text("Uploaded Receipts"),
              actions: [
                PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem<int>(
                          value: 0,
                          child: Text("Add Receipt"),
                        ),
                        PopupMenuItem<int>(
                          value: 1,
                          child: const Text("Sort by value"),
                          onTap: () => _sortByValue(),
                        ),
                        PopupMenuItem<int>(
                          value: 2,
                          child: const Text("Sort by newest"),
                          onTap: () => _sortByDateDescending(),
                        ),
                        PopupMenuItem<int>(
                          value: 3,
                          child: const Text("Sort by oldest"),
                          onTap: () => _sortByDateAscending(),
                        ),
                      ];
                    },
                    onSelected: (value) => {
                          if (value == 0)
                            {
                              _showUploadReceiptPage(),
                            }
                        })
              ],
            ),
            floatingActionButton: ElevatedButton(
              onPressed: () => _showUploadReceiptPage(),
              child: FittedBox(
                  child: Row(
                children: const [
                  Icon(Icons.add),
                  Text("Add receipt"),
                ],
              )),
              style: Global.defaultButtonStyle,
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: _getStream(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Text("Loading"));
                } else if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text("An unknown error has occurred"));
                  } else if (snapshot.hasData) {
                    return RefreshIndicator(
                        onRefresh:() => _onRefresh(),

                        child: _getDocumentListView(snapshot));                  }
                }
                return RefreshIndicator(
                    onRefresh: () => _onRefresh(),
                    child: _getDocumentListView(snapshot));
              },
            )));
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

  _showUploadReceiptPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const ReceiptUploadPage()));
  }

  _showEditReceiptPage(
      {required Map<String, dynamic> receiptData, required String? receiptID}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => EditReceiptPage(
                  receiptData: receiptData,
                  receiptID: receiptID,
                )));
  }

  _deleteReceipt(String documentID) {
    _loadingToast();
    FirebaseFirestore.instance
        .doc("users/${Global.auth.currentUser!.uid}/receipts/$documentID")
        .delete()
        .then((value) => {_successToast(), _updateCumulativeTotal()})
        .catchError((onError) => _errorToast());
  }

  //Updates the users document in Firestore with the cumulative total of all receipts and amount of receipts uploaded
  Future<void> _updateCumulativeTotal() async {
    final receiptCollectionReference =
        dbRef.doc(Global.auth.currentUser?.uid).collection('receipts');

    double total = 0;

    final receiptQuerySnapshot = await receiptCollectionReference.get();

    for (var receiptDocument in receiptQuerySnapshot.docs) {
      var tempTotal = double.parse(receiptDocument.get('total').toString());
      total += tempTotal;
    }

    dbRef.doc(Global.auth.currentUser?.uid).update(<String, dynamic>{
      'total': double.parse(total.toStringAsFixed(2)),
      'uploadedReceipts': receiptQuerySnapshot.docs.length,
    });
  }

  _successToast() {
    showToast(
      'Successfully deleted receipt!',
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

  _errorToast() {
    showToast(
      'Delete failed!',
      position: ToastPosition.bottom,
      backgroundColor: Colors.red,
      radius: 10.0,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.035,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

  _loadingToast() {
    showToast(
      'Deleting...',
      position: ToastPosition.bottom,
      backgroundColor: Colors.grey,
      radius: 10.0,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.035,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
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

  Widget _getDocumentListView(AsyncSnapshot<QuerySnapshot> snapshot) {
    return ListView(
      children: snapshot.data!.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> receiptData =
            document.data()! as Map<String, dynamic>;
        double total = receiptData['total'] / 100;
        String? comment = receiptData['comment'];
        int? date = receiptData['date'];
        Uint8List image = base64Decode(receiptData['image']);
        String expenseType = receiptData['expenseType'];

        return InkWell(
          onTap: () async => {
            selectedValue = await showMenu<int>(
              context: context,
              items: [
                PopupMenuItem<int>(
                  value: 0,
                  child: FittedBox(
                      child: Row(
                    children: const [
                      Icon(Icons.edit),
                      Global.defaultIconSpacing,
                      Text("Edit receipt"),
                    ],
                  )),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: FittedBox(
                      child: Row(
                    children: const [
                      Icon(Icons.delete_outline),
                      Global.defaultIconSpacing,
                      Text("Delete receipt")
                    ],
                  )),
                )
              ],
              position: RelativeRect.fromLTRB(
                  0,
                  _tapDownDetails.globalPosition.dy,
                  _tapDownDetails.globalPosition.dx,
                  0),
            ),
            if (selectedValue == 0)
              {
                _showEditReceiptPage(
                    receiptData: receiptData, receiptID: document.id)
              }
            else if (selectedValue == 1)
              {
                _deleteReceipt(document.id),
              }
          },
          onTapDown: (tapDownDetails) => _tapDownDetails = tapDownDetails,
          child: Container(
              margin: const EdgeInsets.all(10),
              color: const Color.fromARGB(100, 121, 121, 121),
              child: Column(
                children: [
                  Image.memory(image),

                  Text(
                    "Total: ${NumberFormat.simpleCurrency().format(total)}",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),

              Text("Expense type: $expenseType", style: const TextStyle(
                fontSize: 18,
              )),
              Text("Comment: ${(comment != null || comment == "" ? comment : "none")}",
                        style: const TextStyle(
                          fontSize: 18,
                        )),

                  //Ternary operation to ensure build() doesn't break on the off-chance an upload date isn't stored
                  Text("Uploaded on: ${(date is int ? "${_getDateUploaded(date)} at ${_getTimeUploaded(date)}" : "Unknown")}")

              ])),
        );
      }).toList(),
    );
  }

  _getDateUploaded(int time) {
    return DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY)
        .format(DateTime.fromMicrosecondsSinceEpoch(time));
  }

  _getTimeUploaded(int time) {
    return DateFormat(DateFormat.HOUR_MINUTE)
        .format(DateTime.fromMicrosecondsSinceEpoch(time));
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _receiptStream = _getStream());
  }
}
