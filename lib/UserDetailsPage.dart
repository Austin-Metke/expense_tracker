import 'package:flutter/material.dart';

import 'Global.dart';

class UserDetailsPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const UserDetailsPage({Key? key, required this.userData}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {

  int? uploadedReceipts;
  double? cumulativeTotal;
  String? name;


  @override
  void initState() {
    super.initState();

    uploadedReceipts = widget.userData['uploadedReceipts'];
    cumulativeTotal = widget.userData['total'];
    name = widget.userData['name'];

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        centerTitle: true,
        title: Text("Details for $name"),
        backgroundColor: Global.colorBlue,
      ),

      body: Center(
    child: Column(


        children: [

           Row(
             mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$name's total for the week: ", style: const TextStyle(
                fontSize: 20,
              )),
              Text("\$ ${cumulativeTotal ?? 0}", style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),)
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text("Receipts for the week: ", style: TextStyle(
                fontSize: 20,
              )),

              Text("${uploadedReceipts ?? 0}", style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ))
            ],
          )



        ],


      ),

      ));
  }
}
