import 'Global.dart';

class User {
  String? name;
  String? password;
  String? email;
  String? oldEmail;
  bool? isManager;
  String? phoneNumber;

  toJson() => _serializeToJson(this);

  User(
      {required String? name,
      required String? password,
      required String? email,
        String? oldEmail,
      required bool? isManager,
      required String? phoneNumber}) {
    this.name = name;
    this.password = password;
    this.email = email;
    this.oldEmail = oldEmail;
    this.isManager = isManager;
    this.phoneNumber = phoneNumber;
  }

  Future<Map<String, dynamic>> _serializeToJson(User user) async {

    if(user.oldEmail == user.email) {
      return <String, dynamic>{
        "name": user.name,
        "password": user.password,
        "phoneNumber": user.phoneNumber,
        "email": user.email,
        //To do CRUD operations on a user, Java Web Token must be sent alongside user data
        'jwt': await Global.auth.currentUser?.getIdToken(),
        'isManager': user.isManager,
      };
    } else {

      return <String, dynamic> {

        "name": user.name,
        "password": user.password,
        "phoneNumber": user.phoneNumber,
        "email": user.email,
        "oldEmail": user.oldEmail,
        //To do CRUD operations on a user, Java Web Token must be sent alongside user data
        'jwt': await Global.auth.currentUser?.getIdToken(),
        'isManager': user.isManager,


      };
    }


  }

}
