import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:oktoast/oktoast.dart';
import '../Global.dart';
import '../DataTypes/User.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({Key? key}) : super(key: key);

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _key = GlobalKey<FormState>();

  late String? _name;
  late String _phoneNumber;
  late bool? _isManager = false;

  int? selectedItem = 0;

  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Global.colorBlue,
              centerTitle: true,
              title: const Text("Add a user"),
            ),
            body: Form(
                key: _key,
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Name",
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(Global.defaultRadius)),
                            ),
                            prefixIcon: Icon(Icons.person),
                            hintText: "Name",
                          ),
                          validator: (value) => _nameValidator(value),
                          onChanged: (value) => _name = value),
                    ),

                    //Phone number
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: phoneNumberField(),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: DropdownButton<int>(
                        value: selectedItem,
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: const Text("Employee"),
                            onTap: () => {_isManager = false},
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: const Text("Manager"),
                            onTap: () => {_isManager = true},
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => selectedItem = value),
                      ),
                    ),

                    TextButton(
                      style: Global.defaultButtonStyle,
                      onPressed: () async => {
                        if (_key.currentState!.validate()) {await _createUser()}
                      },
                      child: const Text("Create user"),
                    )
                  ],
                )))));
  }

  Widget phoneNumberField() => TextFormField(
        decoration: const InputDecoration(
          labelText: "Phone number",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(Global.defaultRadius)),
          ),
          prefixIcon: Icon(Icons.dialpad_outlined),
          hintText: "Phone number",
        ),
        validator: (value) => _phoneNumberValidator(
            toNumericString(value, allowPeriod: false, allowHyphen: false)),
        onChanged: (value) =>
            _phoneNumber = toNumericString(value, allowHyphen: false),
        onFieldSubmitted: (value) => _key.currentState?.validate(),
        keyboardType: TextInputType.phone,
        inputFormatters: [Global.phoneInputFormatter],
      );

  _nameValidator(String? value) {
    if (value!.isEmpty) {
      return 'please enter a name';
    }
    return null;
  }

  _phoneNumberValidator(String? value) {
    if (value!.isEmpty || value.length < Global.phoneNumberLength) {
      return 'Please enter a valid phone number';
    }

    //return null if text is valid
    return null;
  }

  Future<void> _createUser() async {
    _loadingToast();

    String? functionStatus = await _createUserCloudFunction(
        user: User(
            name: _name,
            isManager: _isManager,
            email: '$_phoneNumber@fakeemail.com',
            phoneNumber: _phoneNumber));

    switch (functionStatus) {
      case 'auth/email-already-exists':
        _userAlreadyExistsToast();
        break;

      case 'success':
        _successToast();
        break;
      default:
        _errorToast();
    }
  }

  Future<String?> _createUserCloudFunction({required User user}) async {
    HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-west2')
        .httpsCallable('makeUser');
    final resp = await callable.call(user.toJson());
    return resp.data;
  }


  _successToast() {
    showToast(
      'User \'$_name\' successfully created!',
      position: ToastPosition.bottom,
      backgroundColor: Colors.greenAccent.shade400,
      radius: Global.defaultRadius,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.035,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

  _userAlreadyExistsToast() {
    showToast(
      'A user with that phone number already exists',
      position: ToastPosition.bottom,
      backgroundColor: Colors.red,
      radius: Global.defaultRadius,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.035,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

  _loadingToast() {
    showToast(
      'Creating user...',
      position: ToastPosition.bottom,
      backgroundColor: Colors.grey,
      radius: Global.defaultRadius,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.035,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
      duration: const Duration(days: 365),
    );
  }

  _errorToast() {
    showToast(
      'An unknown error occurred!',
      position: ToastPosition.bottom,
      backgroundColor: Colors.red,
      radius: Global.defaultRadius,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.035,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }
}
