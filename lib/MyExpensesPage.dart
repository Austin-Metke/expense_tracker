import 'package:cloud_firestore/cloud_firestore.dart';
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
            if(snapshot.data!['receiptsUploaded'] == 0) {
              return const Center(child: Text("No expenses have been made"));
            } else {
              return RefreshIndicator(
                  child: _getChartListView(snapshot), onRefresh: _onRefresh);
            }
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
    int receiptsUploaded = snapshot.data!['receiptsUploaded'].toInt();

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

    final expenses = await FirebaseFirestore.instance.collection('stats').doc(Global.auth.currentUser!.uid).get();

    final double foodTotal = expenses.get('foodTotal').toDouble()/100;
    final double toolsTotal = expenses.get('toolsTotal').toDouble()/100;
    final double travelTotal = expenses.get('travelTotal').toDouble()/100;
    final double otherTotal = expenses.get('otherTotal').toDouble() /100;
    final double cumulativeTotal = expenses.get('receiptTotal').toDouble() /100;

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
      "receiptsUploaded": receiptCount,
      "pieChartData": pieChartData,
      "columnChartData": columnChartData,
    };
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() => {});
  }
}
