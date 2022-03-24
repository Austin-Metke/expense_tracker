import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'ChartData.dart';
import 'Global.dart';
import 'Receipt.dart';

class MyExpensesPage extends StatefulWidget {
  const MyExpensesPage({Key? key}) : super(key: key);

  @override
  _MyExpensesPageState createState() => _MyExpensesPageState();
}

class _MyExpensesPageState extends State<MyExpensesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Expenses"),
        centerTitle: true,
        backgroundColor: Global.colorBlue,
        automaticallyImplyLeading: false,
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
            return RefreshIndicator(
                child: _getChartListView(snapshot), onRefresh: _onRefresh);
          }

          return Container();
        },
      ),
    );
  }

  ListView _getChartListView(AsyncSnapshot<Map<String, dynamic>> snapshot) {
    var columnChartData = snapshot.data!['columnChartData'];
    var pieChartData = snapshot.data!['pieChartData'];
    double total = snapshot.data!['total'];
    var receiptsUploaded = snapshot.data!['receiptsUploaded'];

    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SfCircularChart(
              borderWidth: 2,
              borderColor: Colors.black,
              title: ChartTitle(
                  text:
                      "My Expenses for The Week:  ${total == 0 ? "none" : "\$ ${total.toStringAsFixed(2)}"}"),
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

  Future<Map<String, dynamic>> _getChartData() async {
    final userDoc = await FirebaseFirestore.instance
        .doc("users/${Global.auth.currentUser!.uid}")
        .get();

    HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-west2')
        .httpsCallable('getMyExpenses');

    final resp = await callable();

    final expenses = resp.data as List<dynamic>;

    final foodExpenses = expenses.elementAt(0).toDouble();
    final toolsExpenses = expenses.elementAt(1).toDouble();
    final travelExpenses = expenses.elementAt(2).toDouble();
    final otherExpenses = expenses.elementAt(3).toDouble();
    final totalExpenses = userDoc.get("total").toDouble() / 100;
    final foodExpensesMade = expenses.elementAt(4).toDouble();
    final toolsExpensesMade = expenses.elementAt(5).toDouble();
    final travelExpensesMade = expenses.elementAt(6).toDouble();
    final otherExpensesMade = expenses.elementAt(7).toDouble();
    final totalExpensesMade = userDoc.get("uploadedReceipts");

    var pieChartData = <ChartData>[
      ChartData(ExpenseType.food, foodExpenses, Colors.green),
      ChartData(ExpenseType.tools, toolsExpenses, Colors.purple),
      ChartData(ExpenseType.travel, travelExpenses, Colors.blue),
      ChartData(ExpenseType.other, otherExpenses, Colors.red),
    ];

    var columnChartData = <ChartData>[
      ChartData(ExpenseType.food, foodExpensesMade, Colors.green),
      ChartData(ExpenseType.tools, toolsExpensesMade, Colors.purple),
      ChartData(ExpenseType.travel, travelExpensesMade, Colors.blue),
      ChartData(ExpenseType.other, otherExpensesMade, Colors.red),
    ];

    return <String, dynamic>{
      'total': totalExpenses,
      "receiptsUploaded": totalExpensesMade,
      "pieChartData": pieChartData,
      "columnChartData": columnChartData,
    };
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() => {});
  }
}
