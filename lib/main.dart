import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:expense_tracker/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:flutter/services.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ExpenseTracker());

}


class ExpenseTracker extends StatelessWidget {
  const ExpenseTracker({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {

    return const MaterialApp(

      home: Scaffold(

        resizeToAvoidBottomInset: false,
        body: LoginPage()
      )

    );


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





 _submitForm() async {

    final formState = _key.currentState;

    if(formState!.validate()) {



      print("Valid form! $_phoneNumber $_password");


    }
  }

  @override
  Widget build(BuildContext context) {

    return Center(

      widthFactor: double.infinity,
      heightFactor: 3.25,
      child: Form(

          key: _key,

          child: SingleChildScrollView(

            child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [




              //Phone number field
              TextFormField(

                decoration: const InputDecoration(

                  prefixIcon: Icon(Icons.dialpad_outlined),

                  hintText: "Phone number",

                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),

                ),

                validator: (value) {

                  if(!phoneNumberRegex.hasMatch(value!) || value.isEmpty || value.length < phoneNumberLength) {

                    return 'Please enter a valid phone number';
                  }

                  //return null if text is valid
                  return null;

                },


                onChanged: (value) => _phoneNumber = value,


                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter(
                      phoneNumberRegex,
                      allow: true),
                  LengthLimitingTextInputFormatter(phoneNumberLength)
                ],

              ),



              //Password Field
              TextFormField(

                decoration: InputDecoration(

                    prefixIcon: Icon(Icons.lock),
                    hintText: "Password",
                    suffixIcon: GestureDetector(

                      child: _visPass ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),

                      onTap: () => setState(() {
                        _visPass = !_visPass;
                      })
                    ),

                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),


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


              ),



              TextButton(

                style: ButtonStyle(

                  backgroundColor: MaterialStateProperty.all<Color>(Colors.lightGreen),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),

                ),


                onPressed: () {_submitForm();}, child: const Text("Login"),

              )


            ],

          ),



        ),


      )
    );


  }


}

class User {

  var _username;
  var _passwordHash;

  createUser(String username, String password) {

    _username = username;
    _passwordHash = DBCrypt().hashpw(password, DBCrypt().gensalt());


  }

  delUser(User user) {

    user._passwordHash = null;
    user._username = null;

  }

  getHash() {

    return _passwordHash;

  }

  getUsername() {
    return _username;
  }






}