import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:oktoast/oktoast.dart';
import 'Global.dart';
import 'Receipt.dart';

class ReceiptUploadPage extends StatefulWidget {
  const ReceiptUploadPage({Key? key}) : super(key: key);

  @override
  _ReceiptUploadPageState createState() => _ReceiptUploadPageState();
}

class _ReceiptUploadPageState extends State<ReceiptUploadPage> {
  final _key = GlobalKey<FormState>();
  File? _image;
  double? _receiptTotal;
  String? _comment;
  final _format = CurrencyTextInputFormatter(
      symbol: "\$ ", decimalDigits: 2, turnOffGrouping: true);
  var auth = FirebaseAuth.instance;
  var dbRef = FirebaseFirestore.instance.collection('users');
  var _enableButton = true;
  final _characterLimit = 300;

  @override
  Widget build(BuildContext context) {
    return OKToast(
        radius: 10,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Upload Receipt"),
          ),
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Form(
              key: _key,
              child: Column(
                children: <Widget>[
                  //*************Image*************
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      child: _image != null
                          ? Image.file(
                              _image!,
                              filterQuality: FilterQuality.medium,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 150,
                              height: 150,
                              color: Colors.black12,
                              child: Center(
                                child: Text(
                                  "Please Select image",
                                  style: TextStyle(
                                    color: _validateImage(_image)
                                        ? Colors.black
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  //***********************

                  //*************ImageButtons*************
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[

                             TextButton(
                              style: Global.defaultButtonStyle,
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.photo_library_outlined,
                                    size: MediaQuery.of(context).size.width *
                                        0.050,
                                  ),

                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.0150,
                                  ),

                                  Text(
                                    "Pick image from gallery",
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.035,
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: () => getImage(),
                            ),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.0150,
                          ),

                          TextButton(
                              style: Global.defaultButtonStyle,
                              onPressed: () => getCamera(),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.camera_alt,
                                      size: MediaQuery.of(context).size.width *
                                          0.050,
                                    ),

                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.0150,
                                    ),

                                    Text(
                                      "Take picture of receipt",
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.035,
                                      ),
                                    ),
                                  ]),
                            ),
                        ]),
                  ),

                  //************TotalFormField***********
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Receipt Total",
                        hintText: _format.format('000'),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      showCursor: true,
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          _receiptTotal = double.parse(value.substring(2)),
                      onFieldSubmitted: (value) =>
                          _key.currentState?.validate(),
                      validator: (value) => _validateTotal(value),
                      inputFormatters: [_format],
                    ),
                  ),
                  //**********************************

                  //***********CommentFormField*********
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Comment",
                        hintText: "Add a comment (optional)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onChanged: (value) => _comment = value,
                      validator: (value) => _validateComment(value),
                      onFieldSubmitted: (value) =>
                          _key.currentState?.validate(),
                      maxLength: _characterLimit,
                    ),
                  ),
                  //**********************************

                  //************UploadButton**********
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: 150,
                      child: TextButton(
                        style: Global.defaultButtonStyle,
                        child: Text("Upload", style: TextStyle(fontSize: MediaQuery.of(context).size.width *
                            0.035)),
                        //Ternary operation to ensure _uploadReceipt() isn't called during an upload
                        onPressed: () =>
                            _enableButton ? _uploadReceipt() : null,
                      ),
                    ),
                  ),
                  //*********************************
                ],
              ),
            ),
          ),
        ));
  }

  Future getImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageFile = File(image.path);

      setState(() => _image = _stripImage(imageFile));
    } on PlatformException catch (e) {
      print("Access to gallery was denied $e");
    }
  }

  Future getCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imageAsFile = File(image.path);

      var strippedImage = await _stripImage(imageAsFile);

      setState(() => _image = strippedImage);
    } on PlatformException catch (e) {
      _galleryDeniedToast();
    }
  }

  Future<void> _uploadReceipt() async {
    final formState = _key.currentState;

    if (formState!.validate() && _validateImage(_image)) {
      _uploadWait();

      final Receipt receipt =
          Receipt(image: _image, total: _receiptTotal, comment: _comment);
      await dbRef
          .doc(Global.auth.currentUser?.uid)
          .collection("receipts")
          .add(receipt.toJson())
          .then((value) => _uploadSuccess())
          .onError((error, stackTrace) => _uploadFail());
    }
  }

  _validateTotal(String? value) {
    if (value!.isEmpty ||
        _receiptTotal!.isNaN ||
        double.parse(value.substring(2)) == 0) {
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

  _validateComment(String? value) {
    if (value!.length > _characterLimit) {
      return 'Comment is too long';
    }

    return null;
  }

  Future<File?> _compressImage(File? image) async {
    final filepath = image?.absolute.path;

    var compressedImage = await FlutterNativeImage.compressImage(
      filepath!,
      percentage: 50,
      quality: 20,
    );

    return compressedImage;
  }

  _stripImage(File? image) {
    var compressImage = _compressImage(image);

    //TODO Create method to make image monochrome

    return compressImage;
  }

  _uploadFail() {
    _errorToast();
    _enableButton = true;
  }

  _uploadSuccess() {
    _successToast();
    _enableButton = true;
  }

  _uploadWait() {
    _loadingToast();
    setState(() => _enableButton = false);
  }

  _successToast() {
    showToast(
      'Upload complete!',
      position: ToastPosition.bottom,
      backgroundColor: Colors.greenAccent.shade400,
      radius: 10.0,
      textStyle: TextStyle(fontSize: MediaQuery.of(context).size.width *
          0.035, color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

  _errorToast() {
    showToast(
      'Upload failed!',
      position: ToastPosition.bottom,
      backgroundColor: Colors.red,
      radius: 10.0,
      textStyle: TextStyle(fontSize: MediaQuery.of(context).size.width *
          0.035, color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

  _galleryDeniedToast() {
    showToast(
      'Unable to access gallery!',
      position: ToastPosition.bottom,
      backgroundColor: Colors.red,
      radius: 10.0,
      textStyle: TextStyle(fontSize: MediaQuery.of(context).size.width *
          0.035, color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }


  _loadingToast() {
    showToast(
      'Uploading...',
      position: ToastPosition.bottom,
      backgroundColor: Colors.grey,
      radius: 10.0,
      textStyle: TextStyle(fontSize: MediaQuery.of(context).size.width *
          0.035, color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

}
