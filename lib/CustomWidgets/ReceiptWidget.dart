import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiptWidget extends StatefulWidget {
  final String? expenseType;
  final String? comment;
  final Uint8List? image;
  final int? date;
  final double? total;
  final Color? backgroundColor;
  final EdgeInsets? imagePadding;
  final TextStyle? totalTextStyle;
  final TextStyle? commentTextStyle;
  final TextStyle? dateTextStyle;
  final TextStyle? expenseTypeTextStyle;

  const ReceiptWidget(
      {Key? key,
      required this.expenseType,
      required this.comment,
      required this.image,
      required this.date,
      required this.total,
      this.backgroundColor,
      this.imagePadding,
      this.totalTextStyle,
      this.commentTextStyle,
      this.dateTextStyle,
      this.expenseTypeTextStyle})
      : super(key: key);

  @override
  _ReceiptWidgetState createState() => _ReceiptWidgetState();
}

class _ReceiptWidgetState extends State<ReceiptWidget> {
  Uint8List? _image;
  String? _expenseType;
  String? _comment;
  int? _date;
  double? _total;
  Color? _backgroundColor;
  TextStyle? _totalTextStyle;
  TextStyle? _commentTextStyle;
  TextStyle? _dateTextStyle;
  TextStyle? _expenseTypeTextStyle;
  final TextStyle? _defaultTextStyle = const TextStyle(fontSize: 18);

  @override
  void initState() {
    super.initState();
    _image = widget.image;
    _comment = widget.comment;
    _expenseType = widget.expenseType;
    _date = widget.date;
    _total = widget.total;
    _backgroundColor = widget.backgroundColor;
    _totalTextStyle = widget.totalTextStyle;
    _commentTextStyle = widget.commentTextStyle;
    _dateTextStyle = widget.dateTextStyle;
    _expenseTypeTextStyle = widget.expenseTypeTextStyle;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: _backgroundColor,
        child: Column(children: [
          Image.memory(_image!),
          Text(
            "Total: ${NumberFormat.simpleCurrency().format(_total)}",
            style: (_totalTextStyle ?? _defaultTextStyle),
          ),
          Text("Expense type: $_expenseType",
              style: (_expenseTypeTextStyle ?? _defaultTextStyle)),
          Text(
              "Comment: ${(_comment != null || _comment == "" ? _comment : "none")}",
              style: (_commentTextStyle ?? _defaultTextStyle)),
          Text(
              "Uploaded on: ${(_date is int ? "${_getDateUploaded(_date!)} at ${_getTimeUploaded(_date!)}" : "Unknown")}",
          style: (_dateTextStyle ?? _defaultTextStyle),
          )
        ]));
  }

  _getDateUploaded(int time) {
    return DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY)
        .format(DateTime.fromMicrosecondsSinceEpoch(time));
  }

  _getTimeUploaded(int time) {
    return DateFormat(DateFormat.HOUR_MINUTE)
        .format(DateTime.fromMicrosecondsSinceEpoch(time));
  }
}
