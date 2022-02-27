import 'package:expense_tracker/UserFunctions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';


import 'Global.dart';

class ExpenseTracker extends StatelessWidget {
  const ExpenseTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: Scaffold(resizeToAvoidBottomInset: true, body: LoginPage()));
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _key = GlobalKey<FormState>();

  final phoneNumberRegex = RegExp(r'^[0-9]*$');
  final phoneNumberLength = 10;
  late String _phoneNumber;
  late String _password;
  late bool _visPass = false;
  late bool? _userNotFound = false;
  late bool? _wrongPassword = false;
  late bool? _tooManyRequests = false;

  _submitForm() async {
    final formState = _key.currentState;

    if (formState!.validate()) {
      var credential = EmailAuthProvider.credential(
          email: _phoneNumber + "@fakeemail.com", password: _password);
      print("Valid form! $_phoneNumber $_password");

      try {
        print("TEST");
        await Global.auth.signInWithCredential(credential).then((value) => _showUserFunctionPage()).onError((error, stackTrace) => print("ERROR: $error, STACKTRACE: $stackTrace"));
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

            const Image(
                image: AssetImage("assets/cvcenterprise.png"),
                height: 188,
                width: 400),

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
                  child: Text("Forgot password?",
                      style: TextStyle(
                        fontSize: 18,
                        color: Global.colorBlue,
                      )),
                  onTap: () => _forgotPassword(),
                )),

            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: GestureDetector(
                  child: Text("¿Hablas Español?",
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
        validator: (value) => _phoneNumberValidator(value),
        onChanged: (value) => _phoneNumber = value,
        onFieldSubmitted: (value) => _key.currentState?.validate(),
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter(phoneNumberRegex, allow: true),
          LengthLimitingTextInputFormatter(phoneNumberLength)
        ],
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
      obscureText: !_visPass,
      onChanged: (value) => _password = value,
      onFieldSubmitted: (value) => _key.currentState?.validate());

//**********************Login Button**************************
  Widget loginButton() => TextButton(
        style: Global.defaultButtonStyle,
        onPressed: ()  => _submitForm(),
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
    if (!phoneNumberRegex.hasMatch(value!) ||
        value.isEmpty ||
        value.length < phoneNumberLength) {
      return 'Please enter a valid phone number';
    }

    if (_userNotFound!) {
      _userNotFound = false;
      return "User with phone number not exist";
    }

    //return null if text is valid
    return null;
  }

  _showUserFunctionPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const UserFunctionsPage()));
  }
}
