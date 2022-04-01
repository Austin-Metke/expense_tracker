import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/FirebaseOperations/FirestoreActions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:oktoast/oktoast.dart';
import '../Global.dart';
import '../DataTypes/Receipt.dart';

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
  var _enableButton = true;
  String _expenseType = ExpenseType.travel;
  final _characterLimit = 300;
  final dbRef = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return OKToast(
        radius: 10,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Global.colorBlue,
            centerTitle: true,
            title: const Text("Upload Receipt"),
          ),
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Form(
              key: _key,
              child: Column(
                children: <Widget>[
                  //*************Image*******************
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      child: _validateImage(_image)
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
                              child: const Center(
                                child: Text(
                                  "Please Select image",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                    ),
                  ),
                  //**************************************

                  //*************ImageButtons*************
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: FittedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextButton(
                            style: Global.defaultButtonStyle,
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.photo_library_outlined,
                                ),
                                Global.defaultIconSpacing,
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
                                  size:
                                      MediaQuery.of(context).size.width * 0.050,
                                ),
                                Global.defaultIconSpacing,
                                Text(
                                  "Take picture of receipt",
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.035,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //************************************

                  //************TotalFormField***********
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Receipt Total",
                        hintText: "0.00",
                        prefixText: "\$ ",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      initialValue: "0.00",
                      showCursor: true,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _receiptTotal = double.tryParse(
                          toNumericString(value,
                              allowPeriod: false, allowHyphen: false)),
                      onFieldSubmitted: (value) =>
                          _key.currentState?.validate(),
                      validator: (value) => _validateTotal(toNumericString(
                          value,
                          allowHyphen: false,
                          allowPeriod: false)),
                      inputFormatters: [Global.moneyInputFormatter],
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

                  //**********ExpenseTypeDrownDownMenu*********

                  DropdownButton<String>(
                      value: _expenseType,
                      hint: const Text("Expense Type"),
                      items: const [
                        DropdownMenuItem<String>(
                          child: Text("Travel"),
                          value: ExpenseType.travel,
                        ),
                        DropdownMenuItem<String>(
                          child: Text("Food"),
                          value: ExpenseType.food,
                        ),
                        DropdownMenuItem<String>(
                          child: Text("Tools"),
                          value: ExpenseType.tools,
                        ),
                        DropdownMenuItem<String>(
                          child: Text("Other"),
                          value: ExpenseType.other,
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _expenseType = value!)),

                  //**********************************

                  //************UploadButton**********
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: 150,
                      child: TextButton(
                        style: Global.defaultButtonStyle,
                        child: Text("Upload",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.035)),
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

  Future<void> getImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageAsFile = File(image.path);

      var strippedImage = await _stripImage(imageAsFile);

      setState(() => _image = strippedImage);
    } on PlatformException {
      _cameraDeniedToast();
    }

  }

  Future<void> getCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imageAsFile = File(image.path);

      var strippedImage = await _stripImage(imageAsFile);

      setState(() => _image = strippedImage);
    } on PlatformException {
      _galleryDeniedToast();
    }
  }

  Future<void> _uploadReceipt() async {
    final formState = _key.currentState;
    if (formState!.validate() && _validateImage(_image)) {
      _uploadWait();
      try {
        await FirestoreActions.uploadReceipt(
          receipt: Receipt(
              image: _image,
              total: _receiptTotal,
              comment: _comment,
              expenseType: _expenseType),
        );
        _uploadSuccess();
      } catch (e) {
        _uploadFail();
      }
    }
  }

  _validateTotal(String? value) {
    if (value!.isEmpty || _receiptTotal!.isNaN || double.parse(value) == 0) {
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
      percentage: Global.imageCompression,
      quality: Global.imageQuality,
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
      radius: Global.defaultRadius,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.040,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

  _errorToast() {
    showToast(
      'Upload failed!',
      position: ToastPosition.bottom,
      backgroundColor: Colors.red,
      radius: Global.defaultRadius,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.040,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

  _galleryDeniedToast() {
    showToast(
      'Unable to access gallery!',
      position: ToastPosition.bottom,
      backgroundColor: Colors.red,
      radius: Global.defaultRadius,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.040,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

  _cameraDeniedToast() {
    showToast(
      'Unable to access camera!',
      position: ToastPosition.bottom,
      backgroundColor: Colors.red,
      radius: Global.defaultRadius,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.040,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

  _loadingToast() {
    showToast(
      'Uploading...',
      position: ToastPosition.bottom,
      backgroundColor: Colors.grey,
      radius: Global.defaultRadius,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.040,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }
}
