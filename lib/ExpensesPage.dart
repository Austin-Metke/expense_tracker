import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }

  Future<void> _getTotal() async {

    HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-west2').httpsCallable('getTotal');




  }

}
