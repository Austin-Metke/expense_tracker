import 'dart:convert';
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

class EditReceiptPage extends StatefulWidget {
  final Map<String, dynamic> receiptData;
  final String? receiptID;

  const EditReceiptPage(
      {Key? key, required this.receiptData, required this.receiptID})
      : super(key: key);

  @override
  _EditReceiptPageState createState() => _EditReceiptPageState();
}

class _EditReceiptPageState extends State<EditReceiptPage> {
  final _key = GlobalKey<FormState>();

  String? _initialTotal;
  double? _total;
  String? _encodedImage;
  File? _image;
  String? _comment;
  String? _expenseType;
  var _enableButton = true;
  final _characterLimit = 300;
  late final String? _receiptID;
  final dbRef = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    _initialTotal = (widget.receiptData['total'] / 100).toStringAsFixed(2);
    _total = widget.receiptData['total'];
    _comment = widget.receiptData['comment'];
    _encodedImage = widget.receiptData['image'];
    _receiptID = widget.receiptID;
    _expenseType = widget.receiptData['expenseType'];
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
        radius: 10,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Global.colorBlue,
            centerTitle: true,
            title: const Text("Edit receipt"),
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
                        child: _image == null
                            ? Image.memory(
                                base64Decode(_encodedImage!),
                                filterQuality: FilterQuality.medium,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                _image!,
                                filterQuality: FilterQuality.medium,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              )),
                  ),
                  //***********************

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
                              child: FittedBox(
                                  child: Row(
                                children: const <Widget>[
                                  Icon(
                                    Icons.photo_library_outlined,
                                  ),
                                  Global.defaultIconSpacing,
                                  Text(
                                    "Pick image from gallery",
                                  ),
                                ],
                              )),
                              onPressed: () => _getImage(),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.0150,
                            ),
                            TextButton(
                              style: Global.defaultButtonStyle,
                              onPressed: () => _getCamera(),
                              child: FittedBox(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const <Widget>[
                                      Icon(
                                        Icons.camera_alt,
                                      ),
                                      Global.defaultIconSpacing,
                                      Text(
                                        "Take picture of receipt",
                                      ),
                                    ]),
                              ),
                            ),
                          ]),
                    ),
                  ),

                  //************TotalFormField***********
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      initialValue: _initialTotal,
                      decoration: const InputDecoration(
                        labelText: "Receipt Total",
                        prefixText: "\$ ",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      showCursor: true,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _total = double.parse(
                          toNumericString(value,
                              allowHyphen: false, allowPeriod: false)),
                      onFieldSubmitted: (value) =>
                          _key.currentState?.validate(),
                      validator: (value) => _validateTotal(value),
                      inputFormatters: [Global.moneyInputFormatter],
                    ),
                  ),
                  //**********************************

                  //***********CommentFormField*********
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      initialValue: _comment,
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
                      items: const [
                        DropdownMenuItem<String>(
                          child: Text(ExpenseType.travel),
                          value: ExpenseType.travel,
                        ),
                        DropdownMenuItem<String>(
                          child: Text(ExpenseType.food),
                          value: ExpenseType.food,
                        ),
                        DropdownMenuItem<String>(
                          child: Text(ExpenseType.tools),
                          value: ExpenseType.tools,
                        ),
                        DropdownMenuItem<String>(
                          child: Text(ExpenseType.other),
                          value: ExpenseType.other,
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _expenseType = value)),
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
                            _enableButton ? _updateReceipt() : null,
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

  Future _getImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageAsFile = File(image.path);

      var strippedImage = await _stripImage(imageAsFile);

      setState(() => _image = strippedImage);
    } on PlatformException catch (e) {
      _galleryErrorToast();
    }
  }

  Future _getCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imageAsFile = File(image.path);

      var strippedImage = await _stripImage(imageAsFile);

      setState(() => _image = strippedImage);
    } on PlatformException catch (e) {
      _cameraErrorToast();
    }
  }

  Future<void> _updateReceipt() async {
    final formstate = _key.currentState;

    if (formstate!.validate()) {
      _uploadWait();
      try {
        await _updateReceiptCloudFunction(
          receipt: Receipt(
              total: _total,
              comment: _comment,
              expenseType: _expenseType,
              image: _image!),
          receiptID: _receiptID,
        );
        _uploadSuccess();
      } catch (e) {
        _uploadFail();
      }
    }
  }

  Future<void> _updateReceiptCloudFunction(
          {required Receipt receipt, required receiptID}) =>
      FirebaseFirestore.instance
          .doc("users/${Global.auth.currentUser!.uid}/receipts/$receiptID")
          .update(receipt.toJson());

  _validateTotal(String? value) {
    if (value!.isEmpty ||
        _total!.isNaN ||
        double.parse(toNumericString(value)) == 0) {
      return 'Please enter a total for your receipt';
    }

    return null;
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

  _stripImage(File? image) async {
    var compressImage = _compressImage(image);

    //TODO Create a function that makes image grayscale

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

  _cameraErrorToast() {
    showToast(
      'Access to camera was denied!',
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

  _galleryErrorToast() {
    showToast(
      'Access to gallery was denied!',
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
