import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'Global.dart';
import 'User.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({Key? key}) : super(key: key);

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _key = GlobalKey<FormState>();

  late String? _name;
  late String _phoneNumber;
  late String? _password;
  late bool? _isManager = false;

  int? selectedItem = 0;

  @override
  Widget build(BuildContext context) {
    return OKToast(
        radius: 10,
        child: Scaffold(
            appBar: AppBar(
              title: Text("Add a user"),
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
                            child: Text("Employee"),
                            onTap: () => {_isManager = false},
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text("Manager"),
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
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          prefixIcon: Icon(Icons.dialpad_outlined),
          hintText: "Phone number",
        ),
        validator: (value) => _phoneNumberValidator(value),
        onChanged: (value) => _phoneNumber = value,
        onFieldSubmitted: (value) => _key.currentState?.validate(),
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter(Global.phoneNumberRegex, allow: true),
          LengthLimitingTextInputFormatter(Global.phoneNumberLength)
        ],
      );

  _nameValidator(String? value) {
    if (value!.isEmpty) {
      return 'please enter a name';
    }
    return null;
  }

  _phoneNumberValidator(String? value) {
    if (!Global.phoneNumberRegex.hasMatch(value!) ||
        value.isEmpty ||
        value.length < Global.phoneNumberLength) {
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

  Future<void> _createUser() async {
    _loadingToast();

    User user = User(
        name: _name,
        isManager: _isManager,
        email: '$_phoneNumber@fakeemail.com',
        phoneNumber: _phoneNumber,
        password: _password);

    HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-west2')
        .httpsCallable('makeUser');
    final resp = await callable.call(await user.toJson());

    print("RESPONSE: ${resp.data}");

    switch (resp.data) {
      case 'auth/email-already-exists':
        _userAlreadyExists();
        break;

      case 'auth/invalid-password':
        _passwordtooShortToast();
        break;

      case 'success':
        _successToast();
    }
  }

  _successToast() {
    showToast(
      'User \'$_name\' successfully created!',
      position: ToastPosition.bottom,
      backgroundColor: Colors.greenAccent.shade400,
      radius: 10.0,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.035,
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
        fontSize: MediaQuery.of(context).size.width * 0.035,
        color: Colors.white,
      ),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
    );
  }

  _userAlreadyExists() {
    showToast(
      'A user with that phone number already exists',
      position: ToastPosition.bottom,
      backgroundColor: Colors.red,
      radius: 10.0,
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
      radius: 10.0,
      textStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.035,
          color: Colors.white),
      dismissOtherToast: true,
      textAlign: TextAlign.center,
      duration: Duration(days: 365),
    );
  }
}