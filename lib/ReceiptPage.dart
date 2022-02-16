import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

import 'Global.dart';
import 'Receipt.dart';

class ReceiptRoute extends StatefulWidget {
  const ReceiptRoute({Key? key}) : super(key: key);

  @override
  _ReceiptRouteState createState() => _ReceiptRouteState();
}

class _ReceiptRouteState extends State<ReceiptRoute> {
  final _key = GlobalKey<FormState>();
  File? _image;
  double? _receiptTotal;
  final _format = CurrencyTextInputFormatter(
      symbol: "\$ ", decimalDigits: 2, turnOffGrouping: true);
  var auth = FirebaseAuth.instance;
  var dbRef = FirebaseDatabase.instance.ref("users");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
            child: Form(
                key: _key,
                child: Column(children: <Widget>[
                  const Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Upload Receipt",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _image != null
                      ? Image.file(
                          _image!,
                          filterQuality: FilterQuality.medium,
                          width: 150,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 150, height: 150, color: Colors.black12,

                    child: Center(

                      child: Text("Please Select image",

                        style: TextStyle(

                          color: _validateImage(_image) ? Colors.black : Colors.red,

                        ),

                      )

                    )

                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 40,
                          width: 200,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: const StadiumBorder(),
                              maximumSize: Size.infinite,
                              backgroundColor: Global.colorBlue,
                              primary: Colors.white,
                            ),
                            child: Row(
                              children: const <Widget>[
                                Icon(
                                  Icons.photo_library_outlined,
                                ),
                                SizedBox(width: 5),
                                Text("Pick image from gallery"),
                              ],
                            ),
                            onPressed: () => getImage(),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          height: 40,
                          width: 200,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: const StadiumBorder(),
                              maximumSize: Size.infinite,
                              backgroundColor: Global.colorBlue,
                              primary: Colors.white,
                            ),
                            onPressed: () => getCamera(),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const <Widget>[
                                  Icon(Icons.camera_alt),
                                  SizedBox(width: 5),
                                  Text("Take picture of receipt"),
                                ]),
                          ),
                        ),
                      ]),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Receipt Total",
                      hintText: _format.format('000'),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    showCursor: true,
                    keyboardType: TextInputType.number,

                    //Ternary operation prevents substring() error from parsing a null value
                    onChanged: (value) =>
                        _receiptTotal = double.parse(value.substring(2)),
                    onFieldSubmitted: (value) => _key.currentState?.validate(),

                    validator: (value) => _validateTotal(value),
                    inputFormatters: [_format],
                  ),
                  SizedBox(
                      width: 150,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          shape: const StadiumBorder(),
                          maximumSize: Size.infinite,
                          backgroundColor: Global.colorBlue,
                          primary: Colors.white,
                        ),
                        child: Text("Upload"),
                        onPressed: () => _uploadReceipt(),
                      ))
                ]))));
  }

  Future getImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageFile = File(image.path);
      setState(() => _image = imageFile);
    } on PlatformException catch (e) {
      print("Access to gallery was denied $e");
    }
  }

  Future getCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imageFile = File(image.path);

      setState(() => _image = imageFile);
    } on PlatformException catch (e) {
      print("Access to camera was denied $e");
    }
  }

  Future<void> _uploadReceipt() async {
    final formState = _key.currentState;

    
    
    if (formState!.validate() && _validateImage(_image)) {

      final Receipt receipt = Receipt(image: _image, total: _receiptTotal);

      try {
        await dbRef
            .child(auth.currentUser!.uid)
            .child('receipts')
            .push()
            .set(receipt.toJson());
      } on FirebaseException catch (e) {
        print(e.toString());
      }
    }
  }

  _validateTotal(String? value) {
    if (value!.isEmpty || _receiptTotal!.isNaN) {
      return 'Please enter a total for your receipt';
    }

    return null;
  }

  _validateImage(File? value) {
    if (value == null) {

      


      return false;
      
    }
    return true;
  }


}
