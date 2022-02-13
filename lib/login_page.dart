import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class ExpenseTracker extends StatelessWidget {
  const ExpenseTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: Scaffold(resizeToAvoidBottomInset: false, body: LoginPage()));
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
  Color colorBlue = const Color(0xff5d5fef);
  late String _phoneNumber;
  late String _password;
  late bool _visPass = false;
  var auth = FirebaseAuth.instance;

  _submitForm() async {
    final formState = _key.currentState;

    
    if (formState!.validate()) {
      print("Valid form! $_phoneNumber $_password");
      var credential = EmailAuthProvider.credential(email: _phoneNumber + "@fakeemail.com", password: _password);
      try {
        auth.signInWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'user-not-found':
            print("User does not exist");
            break;
          case 'wrong-password':
            print("Wrong password");
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

            const Image(image: AssetImage("assets/cvcenterprise.png"), height: 188, width: 400),

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
            SizedBox(
                height: 40,
                width: 375,
                //padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: loginButton()),

            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: GestureDetector(
                  child: Text("Forgot password?",
                      style: TextStyle(
                        fontSize: 18,
                        color: colorBlue,
                      )),
                  onTap: () => _forgotPassword(),
                )),

            Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: GestureDetector(
                  child: Text("¿Hablas Español?",
                      style: TextStyle(
                        fontSize: 18,
                        color: colorBlue,
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
        validator: (value) {
          if (!phoneNumberRegex.hasMatch(value!) ||
              value.isEmpty ||
              value.length < phoneNumberLength) {
            return 'Please enter a valid phone number';
          }
          //return null if text is valid
          return null;
        },
        onChanged: (value) => _phoneNumber = value,
        onFieldSubmitted: (value) {
          if (!_key.currentState!.validate()) {
            print("Invalid phone number");
          }
        },
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
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your password';
        }

        //return null if text is valid
        return null;
      },
      obscureText: !_visPass,
      onChanged: (value) => _password = value,
      onFieldSubmitted: (value) {
        if (!_key.currentState!.validate()) {
          print("Invalid password");
        }
      });

//**********************Login Button**************************
  Widget loginButton() => TextButton(
        style: TextButton.styleFrom(
          shape: const StadiumBorder(),
          maximumSize: Size.infinite,
          backgroundColor: colorBlue,
          primary: Colors.white,
        ),
        onPressed: () => _submitForm(),
        child: const Text("Login"),
      );

/*  Future<bool> _loginUser(String phoneNumber, BuildContext context) async{

    var _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(phoneNumber: phoneNumber,
        verificationCompleted: (AuthCredential credential) async {

      var result = await _auth.signInWithCredential(credential);

        var user = result.user;


        }, codeAutoRetrievalTimeout: (String verificationId) {  }, verificationFailed: (FirebaseAuthException error) {  }, codeSent: (String verificationId, int? forceResendingToken) {  })


  }*/

  _forgotPassword() {
    print("Forgot password");
  }

  changeLang() {
    print("Change language");
  }
}
