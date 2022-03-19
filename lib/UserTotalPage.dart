import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import'Global.dart';
class UserTotalPage extends StatefulWidget {
  const UserTotalPage({Key? key}) : super(key: key);

  @override
  _UserTotalPageState createState() => _UserTotalPageState();
}

class _UserTotalPageState extends State<UserTotalPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Total expenses for the week"),
        centerTitle: true,
      ),
        body: Column(children: <Widget>[
      FutureBuilder(
        future: _getTotal(),
        builder: ((context, snapshot) {

          if(snapshot.connectionState == ConnectionState.waiting) {
            EasyLoading.show();
          } else if (snapshot.hasData) {

            EasyLoading.dismiss();
            return Center(
              child: Text("Total: ${snapshot.data}"),
            );
          }

          return Container();
        }),
      ),

    ]));
  }
}

Future<double> _getTotal() async {
  HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-west2')
      .httpsCallable('getTotal');
  final resp = await callable();

  final double total = resp.data;
  return total;
}
