import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/DataTypes/Receipt.dart';
import 'package:expense_tracker/Global.dart';
import 'package:flutter/material.dart';

@immutable
abstract class FirestoreActions {
  static Future<void> uploadReceipt(
      {required Receipt receipt}) => FirebaseFirestore.instance.collection('users')
        .doc(Global.auth.currentUser?.uid)
        .collection("receipts").add(receipt.toJson());


  static Future<void> updateReceipt({required Receipt receipt, required receiptID}) => FirebaseFirestore.instance
        .doc("users/${Global.auth.currentUser!.uid}/receipts/$receiptID")
        .update(receipt.toJson());


  static Future<void> deleteReceipt({required receiptID}) => FirebaseFirestore.instance
        .doc("users/${Global.auth.currentUser!.uid}/receipts/$receiptID")
        .delete();


}