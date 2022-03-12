import 'Global.dart';

class User {
  var name;
  var password;
  var email;
  var isManager;
  var phoneNumber;

  toJson() => _serializeToJson(this);

  User(
      {required String? name,
      required String? password,
      required String? email,
      required bool? isManager,
      required String? phoneNumber}) {
    this.name = name;
    this.password = password;
    this.email = email;
    this.isManager = isManager;
    this.phoneNumber = phoneNumber;
  }

  Future<Map<String, dynamic>> _serializeToJson(User user) async {
    return <String, dynamic>{
      "name": user.name,
      "password": user.password,
      "phoneNumber": user.phoneNumber,
      "email": user.email,
      //TODO Fix later
      'jwt': await Global.auth.currentUser?.getIdToken(),
      'isManager': user.isManager,
    };
  }
}
