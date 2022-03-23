import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/EmployeeUploadedReceiptsPage.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'ChartData.dart';
import 'Global.dart';
import 'Receipt.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
    super.initState();
    _name = widget.userData['name'];
    _total = (widget.userData['total'] == null || widget.userData['total'] == 0)
        ? 0
        : widget.userData['total'] / 100;
    _receiptsUploaded = widget.userData['uploadedReceipts'];
    _phoneNumber = widget.userData['phoneNumber'];
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("Details for $_name"),
              actions: [
                PopupMenuButton<int>(
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text("View receipts"),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    switch (value) {
                      case 0:
                        _viewUserReceiptsPage(
                            userPhoneNumber: _phoneNumber, userName: _name);
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
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: !(_receiptsUploaded == 0 ||
                              _receiptsUploaded == null)
                          ? FutureBuilder(
                              future: _getUserDataByTotal(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<ChartData>> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container();
                                } else if (snapshot.hasData) {
                                  if (snapshot.hasError) {
                                    return const Text("Something went wrong");
                                  }
                                  return SfCircularChart(
                                    borderWidth: 2,
                                    borderColor: Colors.black,
                                    title: ChartTitle(
                                        text:
                                            "Expenses for the week:  ${_total == null || _total == 0 ? "none" : "\$ $_total"}"),
                                    legend: Legend(
                                        isVisible: true,
                                        position: LegendPosition.top,
                                        offset: Offset.zero),
                                    series: <CircularSeries>[
                                      PieSeries<ChartData, String>(
                                          radius: "75%",
                                          dataSource: snapshot.data,
                                          pointColorMapper:
                                              (ChartData data, _) => data.color,
                                          xValueMapper: (ChartData data, _) =>
                                              data.x,
                                          yValueMapper: (ChartData data, _) =>
                                              data.y,
                                          dataLabelMapper:
                                              (ChartData data, _) =>
                                                  "\$ ${data.y.toString()}",
                                          legendIconType: LegendIconType.circle,
                                          dataLabelSettings:
                                              const DataLabelSettings(
                                            showZeroValue: false,
                                            isVisible: true,
                                            labelIntersectAction:
                                                LabelIntersectAction.shift,
                                            overflowMode: OverflowMode.shift,
                                            connectorLineSettings:
                                                ConnectorLineSettings(
                                              color: Colors.black,
                                              type: ConnectorType.line,
                                            ),
                                            labelPosition:
                                                ChartDataLabelPosition.outside,
                                          ))
                                    ],
                                  );
                                }
                                return Container();
                              },
                            )
                          : const Text("No expenses made"),
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: !(_receiptsUploaded == 0 ||
                            _receiptsUploaded == null)
                        ? FutureBuilder(
                            future: _getUserDataByReceiptsUploaded(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<ChartData>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              } else if (snapshot.hasData) {
                                if (snapshot.hasError) {
                                  return const Text("Something went wrong");
                                }
                                return SfCartesianChart(
                                    borderWidth: 2,
                                    borderColor: Colors.black,
                                    title: ChartTitle(
                                        text:
                                            "Expenses Made: $_receiptsUploaded"),
                                    primaryXAxis: CategoryAxis(
                                      isVisible: true,
                                    ),
                                    primaryYAxis: NumericAxis(
                                        interval: 1,
                                        isVisible: true,
                                        rangePadding: ChartRangePadding.auto),
                                    series: <ChartSeries<ChartData, String>>[
                                      ColumnSeries<ChartData, String>(
                                        dataSource: snapshot.data!,
                                        xValueMapper: (ChartData data, _) =>
                                            data.x,
                                        yValueMapper: (ChartData data, _) =>
                                            data.y,
                                        pointColorMapper: (ChartData data, _) =>
                                            data.color,
                                      ),
                                    ]);
                              }
                              return Container();
                            },
                          )
                        : Container(),
                  ),
                ],
              ),
            )));
  }

  void _viewUserReceiptsPage(
      {required String? userPhoneNumber, required String? userName}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => EmployeeUploadedReceiptsPage(
                  phoneNumber: userPhoneNumber,
                  name: userName,
                )));
  }

  Future<List<ChartData>> _getUserDataByTotal() async {
    var userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: _phoneNumber)
        .limit(1)
        .get();

    var receiptSnapshot = await FirebaseFirestore.instance
        .collection('users/${userQuery.docs.first.id}/receipts')
        .get();

    double tools = 0;
    double food = 0;
    double other = 0;
    double travel = 0;

    for (var e in receiptSnapshot.docs) {
      switch (e.get('expenseType')) {
        case ExpenseType.food:
          food += e.get('total');
          break;
        case ExpenseType.tools:
          tools += e.get('total');
          break;
        case ExpenseType.other:
          other += e.get('total');
          break;
        case ExpenseType.travel:
          travel += e.get('total');
          break;
      }
    }

    return <ChartData>[
      ChartData(ExpenseType.food, food / 100, Colors.green),
      ChartData(ExpenseType.tools, tools / 100, Colors.purple),
      ChartData(ExpenseType.travel, travel / 100, Colors.blue),
      ChartData(ExpenseType.other, other / 100, Colors.red),
    ];
  }

  Future<List<ChartData>> _getUserDataByReceiptsUploaded() async {
    var userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: _phoneNumber)
        .limit(1)
        .get();

    var receiptSnapshot = await FirebaseFirestore.instance
        .collection('users/${userSnapshot.docs.first.id}/receipts')
        .get();

    int tools = 0;
    int food = 0;
    int other = 0;
    int travel = 0;

    for (var e in receiptSnapshot.docs) {
      switch (e.get('expenseType')) {
        case ExpenseType.food:
          food++;
          break;
        case ExpenseType.tools:
          tools++;
          break;
        case ExpenseType.other:
          other++;
          break;
        case ExpenseType.travel:
          travel++;
          break;
      }
    }
    return <ChartData>[
      ChartData("${ExpenseType.food}: $food", food.toDouble(), Colors.green),
      ChartData(
          "${ExpenseType.tools}: $tools", tools.toDouble(), Colors.purple),
      ChartData(
          "${ExpenseType.travel}: $travel", travel.toDouble(), Colors.blue),
      ChartData("${ExpenseType.other}: $other", other.toDouble(), Colors.red),
    ];
  }
}
