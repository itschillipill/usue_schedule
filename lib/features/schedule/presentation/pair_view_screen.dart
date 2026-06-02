import 'package:flutter/material.dart';
import 'package:usue_schedule/features/schedule/models/pair.dart';

class PairViewScreen extends StatelessWidget {
  const PairViewScreen({super.key, required this.pair});

  final Pair pair;

  static Route<Pair> route({required Pair pair}) {
    return MaterialPageRoute(
      builder: (context) => PairViewScreen(pair: pair),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${pair.number} пара"),
        ),
        body: Center(
          child: Text(pair.pairTime),
        ));
  }
}
