import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/CustomWidgets/ReceiptWidget.dart';
import 'package:expense_tracker/Global.dart';
import 'package:expense_tracker/ReceiptPages/UploadReceiptPage.dart';
import 'package:flutter/material.dart';
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
  int? _selectedValue;
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
                PopupMenuButton(itemBuilder: (context) {
                  return const [
                    PopupMenuItem<int>(
                      value: 0,
                      child: Text("Add Receipt"),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Text("Sort by value"),
                    ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: Text("Sort by newest"),
                    ),
                    PopupMenuItem<int>(
                      value: 3,
                      child: Text("Sort by oldest"),
                    ),
                  ];
                }, onSelected: (value) {
                  switch (value) {
                    case 0:
                      _showUploadReceiptPage();
                      break;
                    case 1:
                      _sortByValue();
                      break;
                    case 2:
                      _sortByDateDescending();
                      break;
                    case 3:
                      _sortByDateAscending();
                      break;
                  }
                }),
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
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: const Center(
                        child: Text(
                            "An unknown error has occurred, please refresh and try again"),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    if (snapshot.data!.size == 0) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: const Center(
                          child: Text("No receipts have been uploaded"),
                        ),
                      );
                    }

                    return RefreshIndicator(
                        onRefresh: () => _onRefresh(),
                        child: _getDocumentListView(snapshot));
                  }
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
    return FirebaseFirestore.instance
        .collection('users/${Global.auth.currentUser!.uid}/receipts')
        .snapshots();
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

  _deleteReceipt({required String receiptID}) async {
    _loadingToast();
    try {
      await _deleteReceiptCloudFunction(receiptID: receiptID);
      _successToast();
    } catch (e) {
      _errorToast();
    }
  }

  Future<void> _deleteReceiptCloudFunction({required receiptID}) =>
      FirebaseFirestore.instance
          .doc("users/${Global.auth.currentUser!.uid}/receipts/$receiptID")
          .delete();

  _successToast() {
    showToast(
      'Successfully deleted receipt!',
      position: ToastPosition.bottom,
      backgroundColor: Colors.greenAccent.shade400,
      radius: Global.defaultRadius,
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
      radius: Global.defaultRadius,
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
      radius: Global.defaultRadius,
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
            _selectedValue = await showMenu<int>(
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
            if (_selectedValue == 0)
              {
                _showEditReceiptPage(
                    receiptData: receiptData, receiptID: document.id)
              }
            else if (_selectedValue == 1)
              {
                _deleteReceipt(receiptID: document.id),
              }
          },
          onTapDown: (tapDownDetails) => _tapDownDetails = tapDownDetails,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: ReceiptWidget(
              comment: comment,
              date: date,
              expenseType: expenseType,
              image: image,
              total: total,
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _receiptStream = _getStream());
  }
}
