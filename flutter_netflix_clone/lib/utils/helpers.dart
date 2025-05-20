import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

String formatDate(String? date) {
  if (date == null || date.isEmpty) return '';
  try {
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
  } catch (e) {
    return '';
  }
}

String? parseDateToIso(String? date) {
  if (date == null || date.isEmpty) return null;
  try {
    final parsed = DateFormat('dd/MM/yyyy').parse(date);
    return DateFormat('yyyy-MM-dd').format(parsed);
  } catch (e) {
    return null;
  }
}