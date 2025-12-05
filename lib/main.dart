import 'package:flutter/material.dart';
import 'package:flutter_benchmark/screens/benchmark_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Benchmark',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const BenchmarkPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
