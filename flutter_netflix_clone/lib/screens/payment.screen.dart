import 'package:flutter/widgets.dart';

class PaymentScreen extends StatefulWidget {
  final String movieId;

  const PaymentScreen({super.key, required this.movieId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Text("Checkout Screen: ${widget.movieId}");
  }
}