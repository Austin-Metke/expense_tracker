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
      {required this.name, required this.password, required this.email, this.oldEmail, required this.isManager, required this.phoneNumber});

  Future<Map<String, dynamic>> _serializeToJson(User user) async {
    return <String, dynamic>{
      "name": user.name,
      "password": user.password,
      "phoneNumber": user.phoneNumber,
      "email": user.email,
      "oldEmail": user.oldEmail,
      'isManager': user.isManager,
    };
  }
}
