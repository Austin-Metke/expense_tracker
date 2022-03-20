import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:oktoast/oktoast.dart';
import 'Global.dart';
import 'User.dart';

class EditUserPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditUserPage({Key? key, required this.userData}) : super(key: key);

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _key = GlobalKey<FormState>();

  late String _password;
  String? _name;
  String? _oldphoneNumber;
  String? _newphoneNumber;
  int? selectedItem;
  bool? _isManager;

  @override
  void initState() {
    super.initState();
    selectedItem = (widget.userData['isManager'] ? 1 : 0);
    _isManager = widget.userData['isManager'];
    _name = widget.userData['name'];
    _oldphoneNumber = widget.userData['phoneNumber'];
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
        radius: 10,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Global.colorBlue,

              title: Text("Edit $_name"),
              centerTitle: true,
            ),
            body: Form(
                key: _key,
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                          initialValue: _name,
                          decoration: const InputDecoration(
                            labelText: "Name",
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
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

                    //Password
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: "User Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          prefixIcon: Icon(Icons.lock),
                          hintText: "User Password",
                        ),
                        validator: (value) => _passwordValidator(value),
                        onChanged: (value) => setState(() => _password = value),
                      ),
                    ),

                    //Confirm password
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Confirm password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          prefixIcon: Icon(Icons.lock),
                          hintText: "Confirm Password",
                        ),
                        validator: (value) => _confirmPasswordValidator(value),
                      ),
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
                        if (_key.currentState!.validate())
                          {
                            await _updateUser(),
                          }
                      },
                      child: const Text("Upload changes"),
                    )
                  ],
                )))));
  }

  Widget phoneNumberField() => TextFormField(
        initialValue: _oldphoneNumber,
        decoration: const InputDecoration(
          labelText: "Phone number",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          prefixIcon: Icon(Icons.dialpad_outlined),
          hintText: "Phone number",
        ),
        validator: (value) => _phoneNumberValidator(toNumericString(value, allowPeriod: false, allowHyphen: false)),
        onChanged: (value) => _newphoneNumber = toNumericString(value, allowHyphen: false, allowPeriod: false),
        onFieldSubmitted: (value) => _key.currentState?.validate(),
        keyboardType: TextInputType.phone,
        inputFormatters: [
          Global.phoneInputFormatter
        ],
      );

  _phoneNumberValidator(String? value) {
    if (value!.isEmpty || value.length < Global.phoneNumberLength) {
      return 'Please enter a valid phone number';
    }
    //return null if text is valid
    return null;
  }

  _passwordValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter a password';
    }

    //return null if text is valid
    return null;
  }

  _confirmPasswordValidator(String? value) {
    if (value!.isEmpty) {
      return 'please enter a password';
    }

    if (value != _password) {
      return 'passwords do not match';
    }

    return null;
  }

  _nameValidator(String? value) {
    if (value!.isEmpty) {
      return 'please enter a name';
    }
    return null;
  }

  _successToast() {
    showToast(
      'User \'$_name\' successfully updated!',
      position: ToastPosition.bottom,
      backgroundColor: Colors.greenAccent.shade400,
      radius: 10.0,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.040,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

  _passwordtooShortToast() {
    showToast(
      'Password must be 6 characters long',
      position: ToastPosition.bottom,
      backgroundColor: Colors.red,
      radius: 10.0,
      textStyle: TextStyle(
        fontSize: MediaQuery.of(context).size.width * 0.040,
        color: Colors.white,
      ),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

  _userAlreadyExistsToast() {
    showToast(
      'A user with that phone number already exists',
      position: ToastPosition.bottom,
      backgroundColor: Colors.red,
      radius: 10.0,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.040,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

  _errorToast() {
    showToast(
      'An unknown error occurred!',
      position: ToastPosition.bottom,
      backgroundColor: Colors.red,
      radius: 10.0,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.040,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }


  _loadingToast() {
    showToast(
      'Uploading changes...',
      position: ToastPosition.bottom,
      backgroundColor: Colors.grey,
      radius: 10.0,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.040,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
      duration: const Duration(days: 365),
    );
  }

  Future<void> _updateUser() async {
    _loadingToast();

    User user = User(
      isManager: _isManager,
      oldEmail: '$_oldphoneNumber@fakeemail.com',
      email: '${_newphoneNumber ?? _oldphoneNumber}@fakeemail.com',
      name: _name,
      password: _password,
      phoneNumber: _newphoneNumber ?? _oldphoneNumber,
    );

    HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-west2')
        .httpsCallable('updateUser');

    final resp = await callable.call(await user.toJson());

    print(resp.data);
    switch (resp.data) {
      case 'auth/email-already-exists':
        _userAlreadyExistsToast();
        break;

      case 'auth/invalid-password':
        _passwordtooShortToast();
        break;

      case 'success':
        _successToast();
        break;
      default:
        _errorToast();
    }
  }
}
