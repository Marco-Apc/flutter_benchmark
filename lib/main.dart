import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

double _performSort(int count) {
  final random = Random(DateTime.now().millisecondsSinceEpoch);
  final list = List<int>.generate(count, (_) => random.nextInt(count));

  final stopwatch = Stopwatch()..start();
  list.sort();
  stopwatch.stop();

  return stopwatch.elapsedMicroseconds / 1000.0;
}

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

class BenchmarkPage extends StatefulWidget {
  const BenchmarkPage({super.key});

  @override
  State<BenchmarkPage> createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends State<BenchmarkPage> {
  final Map<String, String> _results = {};
  late Database _database;
  late String _appDirPath;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final appDir = await getApplicationDocumentsDirectory();
    _appDirPath = appDir.path;

    _database = await openDatabase(
      p.join(_appDirPath, 'benchmark.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE test_entries(id INTEGER PRIMARY KEY, data TEXT)',
        );
      },
    );
    setState(() {});
  }

  Future<void> _runSortTest(int count, String key) async {
    setState(() => _results[key] = "Rodando...");

    final timeInMillis = await compute(_performSort, count);

    setState(() => _results[key] = "${timeInMillis.toStringAsFixed(3)} ms");
  }

  Future<void> _clearDbTable() async {
    await _database.delete('test_entries');
  }

  Future<void> _runDbWriteTest(int count, String key) async {
    setState(() => _results[key] = "Rodando...");

    await _clearDbTable();

    final stopwatch = Stopwatch()..start();

    await _database.transaction((txn) async {
      final batch = txn.batch();
      for (int i = 0; i < count; i++) {
        batch.insert('test_entries', {
          'data': 'Registro #$i - ${DateTime.now().microsecondsSinceEpoch}',
        });
      }
      await batch.commit(noResult: true);
    });

    stopwatch.stop();
    final timeInMillis = stopwatch.elapsedMicroseconds / 1000.0;
    setState(() => _results[key] = "${timeInMillis.toStringAsFixed(3)} ms");
  }

  Future<void> _runDbReadTest(int count, String key) async {
    final writeKey =
        "dbWrite${count ~/ 1000 == 0 ? count : (count ~/ 1000).toString() + 'k'}";
    await _runDbWriteTest(count, _results[writeKey] ?? '-');

    setState(() => _results[key] = "Rodando...");

    final stopwatch = Stopwatch()..start();

    final List<Map<String, dynamic>> maps = await _database.query(
      'test_entries',
      limit: count,
    );

    stopwatch.stop();
    final timeInMillis = stopwatch.elapsedMicroseconds / 1000.0;

    if (maps.length != count) {
      setState(() => _results[key] = "Erro: Lidos ${maps.length} de $count");
    } else {
      setState(() => _results[key] = "${timeInMillis.toStringAsFixed(3)} ms");
    }
  }

  final _random = Random();
  static const _alphanumericChars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  String _generateRandomString(int length) => String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => _alphanumericChars.codeUnitAt(
        _random.nextInt(_alphanumericChars.length),
      ),
    ),
  );

  Future<void> _runFileWriteTest(int charCount, String key) async {
    setState(() => _results[key] = "Rodando...");

    final data = _generateRandomString(charCount);
    final file = File(p.join(_appDirPath, 'benchmark_file_$charCount.txt'));

    final stopwatch = Stopwatch()..start();
    await file.writeAsString(data);
    stopwatch.stop();

    final timeInMillis = stopwatch.elapsedMicroseconds / 1000.0;
    setState(() => _results[key] = "${timeInMillis.toStringAsFixed(3)} ms");
  }

  Future<void> _runFileReadTest(int charCount, String key) async {
    final file = File(p.join(_appDirPath, 'benchmark_file_$charCount.txt'));

    if (!await file.exists()) {
      final writeKey = "fileWrite${charCount ~/ 1000}k";
      await _runFileWriteTest(charCount, _results[writeKey] ?? '-');
    }

    setState(() => _results[key] = "Rodando...");

    final stopwatch = Stopwatch()..start();
    final data = await file.readAsString();
    stopwatch.stop();

    final timeInMillis = stopwatch.elapsedMicroseconds / 1000.0;

    if (data.length != charCount) {
      setState(
        () => _results[key] = "Erro: Lidos ${data.length} de $charCount",
      );
    } else {
      setState(() => _results[key] = "${timeInMillis.toStringAsFixed(3)} ms");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Benchmark')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Testes de CPU (Dual-Pivot Quicksort)'),
            _buildTestRow(
              'sort10k',
              'Sort 10,000',
              () => _runSortTest(10000, 'sort10k'),
            ),
            _buildTestRow(
              'sort100k',
              'Sort 100,000',
              () => _runSortTest(100000, 'sort100k'),
            ),
            _buildTestRow(
              'sort1M',
              'Sort 1,000,000',
              () => _runSortTest(1000000, 'sort1M'),
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Testes de Banco de Dados (SQLite)'),
            _buildTestRow(
              'dbWrite100',
              'Write 100',
              () => _runDbWriteTest(100, 'dbWrite100'),
            ),
            _buildTestRow(
              'dbWrite500',
              'Write 500',
              () => _runDbWriteTest(500, 'dbWrite500'),
            ),
            _buildTestRow(
              'dbWrite1k',
              'Write 1,000',
              () => _runDbWriteTest(1000, 'dbWrite1k'),
            ),
            const SizedBox(height: 8),
            _buildTestRow(
              'dbRead100',
              'Read 100',
              () => _runDbReadTest(100, 'dbRead100'),
            ),
            _buildTestRow(
              'dbRead500',
              'Read 500',
              () => _runDbReadTest(500, 'dbRead500'),
            ),
            _buildTestRow(
              'dbRead1k',
              'Read 1,000',
              () => _runDbReadTest(1000, 'dbRead1k'),
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Testes de Arquivo (I/O)'),
            _buildTestRow(
              'fileWrite1k',
              'Write 1,000',
              () => _runFileWriteTest(1000, 'fileWrite1k'),
            ),
            _buildTestRow(
              'fileWrite10k',
              'Write 10,000',
              () => _runFileWriteTest(10000, 'fileWrite10k'),
            ),
            _buildTestRow(
              'fileWrite100k',
              'Write 100,000',
              () => _runFileWriteTest(100000, 'fileWrite100k'),
            ),
            const SizedBox(height: 8),
            _buildTestRow(
              'fileRead1k',
              'Read 1,000',
              () => _runFileReadTest(1000, 'fileRead1k'),
            ),
            _buildTestRow(
              'fileRead10k',
              'Read 1,0000',
              () => _runFileReadTest(10000, 'fileRead10k'),
            ),
            _buildTestRow(
              'fileRead100k',
              'Read 100,000',
              () => _runFileReadTest(100000, 'fileRead100k'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildTestRow(String key, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(onPressed: onPressed, child: Text(label)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _results[key] ?? '-',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
