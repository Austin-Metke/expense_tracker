import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/NavigationPages/EmployeeNavigationPage.dart';
import 'package:expense_tracker/UserPages/NewUserPasswordChangePage.dart';
import 'package:expense_tracker/NavigationPages/ManagerNavigationPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import '../Global.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class ExpenseTracker extends StatelessWidget {
  const ExpenseTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const OKToast(
      child: MaterialApp(
          home: Scaffold(resizeToAvoidBottomInset: true, body: LoginPage())),
    );
  }
}


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  late String _phoneNumber;
  late String _password;
  bool _showPassword = false;
  bool _userNotFound = false;
  bool _wrongPassword = false;
  bool _tooManyRequests = false;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Form(
      key: _key,
      child: SingleChildScrollView(
        child: Column(
          children: [
            //Temporary Logo
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Image(image: AssetImage("assets/cvcenterprise.png")),
              ),
            ),

            //Phone number field
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: phoneNumberField(),
            ),

            //Password Field
            Padding(
              padding: const EdgeInsets.all(10),
              child: passwordField(),
            ),

            //Login Button
            SizedBox(height: 40, width: 375, child: loginButton()),

            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: GestureDetector(
                  child: const Text("Forgot password?",
                      style: TextStyle(
                        fontSize: 18,
                        color: Global.colorBlue,
                      )),
                  onTap: () => _forgotPassword(),
                )),

            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: GestureDetector(
                  child: const Text("¿Hablas Español?",
                      style: TextStyle(
                        fontSize: 18,
                        color: Global.colorBlue,
                      )),
                  onTap: () => changeLang(),
                )),
          ],
        ),
      ),
    ));
  }

//**********************Phone Number Field*****************************
  Widget phoneNumberField() => TextFormField(
        decoration: const InputDecoration(
          labelText: "Phone number",
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(Global.defaultRadius)),
          ),
          prefixIcon: Icon(Icons.dialpad_outlined),
          hintText: "Phone number",
        ),
        validator: (value) => _phoneNumberValidator(
            toNumericString(value, allowPeriod: false, allowHyphen: false)),
        onChanged: (value) => _phoneNumber =
            toNumericString(value, allowHyphen: false, allowPeriod: false),
        onFieldSubmitted: (value) => _key.currentState?.validate(),
        keyboardType: TextInputType.phone,
        inputFormatters: [Global.phoneInputFormatter],
      );

//**********************Password Field**************************
  Widget passwordField() => TextFormField(
      decoration: InputDecoration(
        labelText: "Password",
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(Global.defaultRadius)),
        ),
        prefixIcon: const Icon(Icons.lock),
        hintText: "Password",
        suffixIcon: GestureDetector(
            child: _showPassword
                ? const Icon(Icons.visibility_off)
                : const Icon(Icons.visibility),
            onTap: () => setState(() {
                  _showPassword = !_showPassword;
                })),
      ),
      validator: (value) => _passwordValidator(value),
      obscureText: !_showPassword,
      onChanged: (value) => _password = value,
      onFieldSubmitted: (value) => _key.currentState?.validate());

  _submitForm() async {
    final formState = _key.currentState;

    if (formState!.validate()) {
      /*
      Firebase does not support logging in with phone number and password.
      So we append "@fakeemail.com" to circumvent it, the end user never sees this
       */
      var emailCredential = EmailAuthProvider.credential(
          email: _phoneNumber + "@fakeemail.com", password: _password);
      try {
        await Global.auth.signInWithCredential(emailCredential);
        var isFirstSignIn = await _isFirstSignIn();
        var isManager = await _isManager();

        if (isFirstSignIn) {
          _showChangePasswordPage(isManager);
        } else {
          _showUserFunctionPage(isManager);
        }
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'user-not-found':
            setState(() => _userNotFound = true);
            formState.validate();
            print("User not found");
            break;
          case 'wrong-password':
            setState(() => _wrongPassword = true);
            formState.validate();
            print("Wrong password");
            break;
          case 'too-many-requests':
            setState(() => _tooManyRequests = true);
            formState.validate();
            print("Too many requests");
            break;

          default:
            print("Unknown error " + e.code);
        }
      }
    }
  }

//**********************Login Button**************************
  Widget loginButton() => TextButton(
        style: Global.defaultButtonStyle,
        onPressed: _submitForm,
        child: const Text("Login"),
      );

  _forgotPassword() {
    //TODO implement forgot password prompt
    print("Forgot password");
  }

  changeLang() {
    //TODO implement language changer
    print("Change language");
  }

  _passwordValidator(String? value) {
    //If nothing is entered
    if (value!.isEmpty) {
      return 'Please enter a password';
    }
    //If password is wrong
    if (_wrongPassword) {
      _wrongPassword = false;
      return 'Password is wrong, please try again';
    }

    //If too many login requests were sent within a certain timeframe
    if (_tooManyRequests) {
      _tooManyRequests = false;
      return 'Too many requests to login, try again later';
    }

    //return null if text is valid
    return null;
  }

  _phoneNumberValidator(String? value) {
    //If text is empty or less than the length of a phone number
    if (value!.isEmpty || value.length < Global.phoneNumberLength) {
      return 'Please enter a valid phone number';
    }

    //If user doesn't exist
    if (_userNotFound) {
      _userNotFound = false;
      return "User with phone number not exist";
    }

    //return null if text is valid
    return null;
  }

  _showUserFunctionPage(bool isManager) async {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => (isManager)
                ? const ManagerNavigationPage()
                : const EmployeeNavigationPage()));
  }

  _showChangePasswordPage(bool isManager) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NewUserPasswordChangePage(isManager: isManager)));
  }
}

Future<bool> _isFirstSignIn() async {
  var isFirstSignIn = await FirebaseFirestore.instance
      .doc('isFirstSignIn/${Global.auth.currentUser!.uid}')
      .get();

  return isFirstSignIn.get('isFirstSignIn');
}

Future<bool> _isManager() async {
  var tokenResult = await Global.auth.currentUser?.getIdTokenResult(true);

  return tokenResult?.claims!['isManager'] as bool;
}
