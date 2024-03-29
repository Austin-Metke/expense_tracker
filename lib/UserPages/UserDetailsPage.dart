import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/ReceiptPages/EmployeeUploadedReceiptsPage.dart';
import 'package:flutter/material.dart';
import '../DataTypes/ChartData.dart';
import '../ReceiptPages/ArchivedReceiptDatePicker.dart';
import '../Global.dart';
import '../DataTypes/Receipt.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class UserDetailsPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String? userDocumentID;

  const UserDetailsPage(
      {Key? key, required this.userData, required this.userDocumentID})
      : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  late String _name;
  late String? _userDocumentID;

  @override
  void initState() {
    super.initState();
    _userDocumentID = widget.userDocumentID;
    _name = widget.userData['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Details for $_name"),
          actions: [
            PopupMenuButton<int>(
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      children: const [
                        Icon(Icons.pages, color: Colors.black38),
                    Global.defaultIconSpacing,
                    Text("View receipts"),
                      ],
                    ),
                  ),

                   PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: const [
                        Icon(Icons.archive, color: Colors.black38),
                        Global.defaultIconSpacing,
                        Text("View archived receipts")
                      ]
                    )

                  ),

                ];
              },
              onSelected: (value) {
                switch (value) {
                  case 0:
                    _viewUserReceiptsPage(
                        userName: _name, userID: _userDocumentID);
                    break;
                  case 1:
                    _viewUserArchivedReceiptsPage(
                        userDocumentID: _userDocumentID, userName: _name);
                }
              },
            ),
          ],
          backgroundColor: Global.colorBlue,
        ),
        body: FutureBuilder(
            future: _getChartData(),
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.none) {
                return Container();
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text("Loading..."));
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return const Text("An unknown error occurred!");
              } else if (snapshot.hasData) {
                if (snapshot.data!['receiptCount'] == 0) {
                  return const Center(child: Text("No expenses have been made"));
                }
                  return RefreshIndicator(
                      child: _getChartListView(snapshot),
                      onRefresh: _onRefresh);
              }
              return Container();
            }));
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() => {});
  }

  _getChartListView(AsyncSnapshot<Map<String, dynamic>> snapshot) {
    var columnChartData = snapshot.data!['columnChartData'];
    var pieChartData = snapshot.data!['pieChartData'];
    double total = snapshot.data!['total'];
    //Data received from cloud firestore gives no type inference, though since we know it returns an integer,
    //We can call .toInt() on it, despite Dart giving it the type of Object.
    int receiptsUploaded = snapshot.data!['receiptCount'].toInt();

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SfCircularChart(
              borderWidth: 2,
              borderColor: Colors.black,
              title: ChartTitle(
                  text:
                      "Expenses for $_name:  ${total == 0 ? "none" : "\$ ${total.toStringAsFixed(2)}"}"),
              legend: Legend(
                  isVisible: true,
                  position: LegendPosition.top,
                  offset: Offset.zero),
              series: <CircularSeries>[
                PieSeries<ChartData, String>(
                    radius: "75%",
                    dataSource: pieChartData,
                    pointColorMapper: (ChartData data, _) => data.color,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    dataLabelMapper: (ChartData data, _) =>
                        "\$ ${data.y.toStringAsFixed(2)}",
                    legendIconType: LegendIconType.circle,
                    dataLabelSettings: const DataLabelSettings(
                      showZeroValue: false,
                      isVisible: true,
                      labelIntersectAction: LabelIntersectAction.shift,
                      overflowMode: OverflowMode.shift,
                      connectorLineSettings: ConnectorLineSettings(
                        color: Colors.black,
                        type: ConnectorType.line,
                      ),
                      labelPosition: ChartDataLabelPosition.outside,
                    ))
              ],
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 0.8,
                child: SfCartesianChart(
                    borderWidth: 2,
                    borderColor: Colors.black,
                    title: ChartTitle(text: "Expenses Made: $receiptsUploaded"),
                    primaryXAxis: CategoryAxis(
                      isVisible: true,
                    ),
                    primaryYAxis: NumericAxis(
                        interval: 1,
                        isVisible: true,
                        rangePadding: ChartRangePadding.auto),
                    series: <ChartSeries<ChartData, String>>[
                      ColumnSeries<ChartData, String>(
                        dataSource: columnChartData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        pointColorMapper: (ChartData data, _) => data.color,
                      ),
                    ]))),
      ],
    );
  }

  void _viewUserReceiptsPage(
      {required String? userID, required String? userName}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => EmployeeUploadedReceiptsPage(
                  userID: userID,
                  name: userName,
                )));
  }

  void _viewUserArchivedReceiptsPage(
      {required String? userDocumentID, required String userName}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => ArchivedReceiptDatePickerPage(
                  userID: userDocumentID,
                  name: userName,
                )));
  }

  Future<Map<String, dynamic>> _getChartData() async {
    final expenses = await FirebaseFirestore.instance
        .collection('stats')
        .doc(_userDocumentID)
        .get();

    final double foodTotal = expenses.get('foodTotal').toDouble() / 100;
    final double toolsTotal = expenses.get('toolsTotal').toDouble() / 100;
    final double travelTotal = expenses.get('travelTotal').toDouble() / 100;
    final double otherTotal = expenses.get('otherTotal').toDouble() / 100;
    final double cumulativeTotal =
        expenses.get('receiptTotal').toDouble() / 100;

    final double foodCount = expenses.get('foodCount').toDouble();
    final double toolsCount = expenses.get('toolsCount').toDouble();
    final double travelCount = expenses.get('travelCount').toDouble();
    final double otherCount = expenses.get('otherCount').toDouble();
    final double receiptCount = expenses.get('receiptCount').toDouble();

    var pieChartData = <ChartData>[
      ChartData(ExpenseType.food, foodTotal, Colors.green),
      ChartData(ExpenseType.tools, toolsTotal, Colors.purple),
      ChartData(ExpenseType.travel, travelTotal, Colors.blue),
      ChartData(ExpenseType.other, otherTotal, Colors.red),
    ];

    var columnChartData = <ChartData>[
      ChartData(ExpenseType.food, foodCount, Colors.green),
      ChartData(ExpenseType.tools, toolsCount, Colors.purple),
      ChartData(ExpenseType.travel, travelCount, Colors.blue),
      ChartData(ExpenseType.other, otherCount, Colors.red),
    ];

    return <String, dynamic>{
      'total': cumulativeTotal,
      "receiptCount": receiptCount,
      "pieChartData": pieChartData,
      "columnChartData": columnChartData,
    };
  }
}
