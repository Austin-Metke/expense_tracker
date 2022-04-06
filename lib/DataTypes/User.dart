class User {
  String? name;
  String? email;
  String? oldEmail;
  bool? isManager;
  String? phoneNumber;

  User(
      {required this.name,
      required this.email,
      this.oldEmail,
      required this.isManager,
      required this.phoneNumber});

  toJson() => _serializeToJson(this);

  Map<String, dynamic> _serializeToJson(User user) {
    return <String, dynamic>{
      "name": user.name,
      "phoneNumber": user.phoneNumber,
      "email": user.email,
      "oldEmail": user.oldEmail,
      'isManager': user.isManager,
    };
  }
}
