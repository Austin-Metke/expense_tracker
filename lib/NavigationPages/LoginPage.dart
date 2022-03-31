import 'package:cloud_functions/cloud_functions.dart';
import 'package:expense_tracker/NavigationPages/EmployeeNavigationPage.dart';
import 'package:expense_tracker/NewUserPasswordChangePage.dart';
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
  late bool _visPass = false;
  late bool? _userNotFound = false;
  late bool? _wrongPassword = false;
  late bool? _tooManyRequests = false;

  final _phoneTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();

  _submitForm() async {
    final formState = _key.currentState;

    if (formState!.validate()) {
      var emailCredential = EmailAuthProvider.credential(
          email: _phoneNumber + "@fakeemail.com", password: _password);
      try {
        var user = await Global.auth.signInWithCredential(emailCredential);
        _phoneTextFieldController.clear();
        _passwordTextFieldController.clear();
        if (user.additionalUserInfo!.isNewUser) {
          //TODO Create change password page for new users
          _showChangePasswordPage();
        }

        _showUserFunctionPage();
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
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          prefixIcon: Icon(Icons.dialpad_outlined),
          hintText: "Phone number",
        ),
        validator: (value) => _phoneNumberValidator(
            toNumericString(value, allowPeriod: false, allowHyphen: false)),
        onChanged: (value) => _phoneNumber =
            toNumericString(value, allowHyphen: false, allowPeriod: false),
        onFieldSubmitted: (value) => _key.currentState?.validate(),
        controller: _phoneTextFieldController,
        keyboardType: TextInputType.phone,
        inputFormatters: [Global.phoneInputFormatter],
      );

//**********************Password Field**************************
  Widget passwordField() => TextFormField(
      decoration: InputDecoration(
        labelText: "Password",
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        prefixIcon: const Icon(Icons.lock),
        hintText: "Password",
        suffixIcon: GestureDetector(
            child: _visPass
                ? const Icon(Icons.visibility_off)
                : const Icon(Icons.visibility),
            onTap: () => setState(() {
                  _visPass = !_visPass;
                })),
      ),
      validator: (value) => _passwordValidator(value),
      controller: _passwordTextFieldController,
      obscureText: !_visPass,
      onChanged: (value) => _password = value,
      onFieldSubmitted: (value) => _key.currentState?.validate());

//**********************Login Button**************************
  Widget loginButton() => TextButton(
        style: Global.defaultButtonStyle,
        onPressed: () => _submitForm(),
        child: const Text("Login"),
      );

  _forgotPassword() {
    print("Forgot password");
  }

  changeLang() {
    print("Change language");
  }

  _passwordValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter a password';
    }
    if (_wrongPassword!) {
      _wrongPassword = false;
      return 'Password is wrong, please try again';
    }

    if (_tooManyRequests!) {
      _tooManyRequests = false;
      return 'Too many requests to login, try again later';
    }

    //return null if text is valid
    return null;
  }

  _phoneNumberValidator(String? value) {
    if (value!.isEmpty || value.length < Global.phoneNumberLength) {
      return 'Please enter a valid phone number';
    }

    if (_userNotFound!) {
      _userNotFound = false;
      return "User with phone number not exist";
    }

    //return null if text is valid
    return null;
  }

  _showUserFunctionPage() async {
    var isManager = await _isManager();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => (isManager)
                ? const ManagerNavigationPage()
                : const EmployeeNavigationPage()));
  }

  _showChangePasswordPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const NewUserPasswordChangePage()));
  }
}

Future<bool> _isManager() async {
  var tokenResult = await Global.auth.currentUser?.getIdTokenResult(true);

  return tokenResult?.claims!['isManager'] as bool;
}
