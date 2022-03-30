import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'ChartData.dart';
import 'Global.dart';
import 'Receipt.dart';

class ExpensesOverviewPage extends StatefulWidget {
  const ExpensesOverviewPage({Key? key}) : super(key: key);

  @override
  _UserTotalPageState createState() => _UserTotalPageState();
}

class _UserTotalPageState extends State<ExpensesOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Weekly Expenses"),
          backgroundColor: Global.colorBlue,
          centerTitle: true,
        ),
        body: Center(
          child: FutureBuilder(
            future: _getExpenses(),
            builder: (BuildContext context, AsyncSnapshot<List<num>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading...");
              } else if (snapshot.hasError) {
                return const Text("An error occurred");
              } else {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                    child: _getExpensesListView(snapshot));
              }
            },
          ),
        ));
  }

  Widget _getExpensesListView(AsyncSnapshot<List<num>> snapshot) {

    final foodExpenses = double.parse(snapshot.data!.elementAt(0).toDouble().toStringAsFixed(2));

    final toolsExpenses = snapshot.data!.elementAt(1).toDouble();
    final travelExpenses = snapshot.data!.elementAt(2).toDouble();
    final otherExpenses = snapshot.data!.elementAt(3).toDouble();
    final totalExpenses =
        snapshot.data?.elementAt(4).toDouble().toStringAsFixed(2);
    final foodExpensesMade = snapshot.data!.elementAt(5).toDouble();
    final toolsExpensesMade = snapshot.data!.elementAt(6).toDouble();
    final travelExpensesMade = snapshot.data!.elementAt(7).toDouble();
    final otherExpensesMade = snapshot.data!.elementAt(8).toDouble();
    final totalExpensesMade = snapshot.data!.elementAt(9);
    var pieChartData = <ChartData>[
      ChartData(ExpenseType.food, foodExpenses, Colors.green),
      ChartData(ExpenseType.tools, toolsExpenses, Colors.purple),
      ChartData(ExpenseType.travel, travelExpenses, Colors.blue),
      ChartData(ExpenseType.other, otherExpenses, Colors.red),
    ];

    var barChartData = <ChartData>[
      ChartData(ExpenseType.food, foodExpensesMade, Colors.green),
      ChartData(ExpenseType.tools, toolsExpensesMade, Colors.purple),
      ChartData(ExpenseType.travel, travelExpensesMade, Colors.blue),
      ChartData(ExpenseType.other, otherExpensesMade, Colors.red),
    ];

    return ListView(
        children: [
          //**************Pie Chart******
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: SfCircularChart(
                title: ChartTitle(text: "Total Expenses: \$ $totalExpenses"),
                borderWidth: 2,
                borderColor: Colors.black,
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
            padding: const EdgeInsets.all(10),
            child: SizedBox(
    child: SfCartesianChart(
              borderWidth: 2,
              borderColor: Colors.black,
              title: ChartTitle(text: "Expenses Made: $totalExpensesMade"),
              primaryXAxis: CategoryAxis(
                isVisible: true,
              ),
              primaryYAxis: NumericAxis(
                  interval: 1,
                  isVisible: true,
                  rangePadding: ChartRangePadding.auto),
              series: <ChartSeries<ChartData, String>>[
                ColumnSeries<ChartData, String>(
                  dataSource: barChartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  pointColorMapper: (ChartData data, _) => data.color,
                ),
              ],
            ),
            ),),
        ],
      );
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }
}

Future<List<num>> _getExpenses() async {
  HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-west2')
      .httpsCallable('getExpenses');
  final resp = await callable();
  final List expenses = resp.data;

  final foodExpenses = expenses.elementAt(0);
  final toolsExpenses = expenses.elementAt(1);
  final travelExpenses = expenses.elementAt(2);
  final otherExpenses = expenses.elementAt(3);
  final totalExpenses = expenses.elementAt(4);
  final foodExpensesMade = expenses.elementAt(5);
  final toolsExpensesMade = expenses.elementAt(6);
  final travelExpensesMade = expenses.elementAt(7);
  final otherExpensesMade = expenses.elementAt(8);
  final totalExpensesMade = expenses.elementAt(9);

  return [
    foodExpenses,
    toolsExpenses,
    travelExpenses,
    otherExpenses,
    totalExpenses,
    foodExpensesMade,
    toolsExpensesMade,
    travelExpensesMade,
    otherExpensesMade,
    totalExpensesMade
  ];
}
