import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../DataTypes/User.dart';

@immutable
abstract class CloudFunctionActions {

  static Future<String?> createUser({required User user}) async {
    HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-west2')
        .httpsCallable('makeUser');
    final resp = await callable.call(await user.toJson());
    return resp.data;
  }

  static Future<String?> updateUser({required User user}) async {
    HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-west2')
        .httpsCallable('updateUser');
    final resp = await callable.call(await user.toJson());
    return resp.data;
  }



}
