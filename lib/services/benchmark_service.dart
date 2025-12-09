import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// Top-level function for compute
double _performSort(int count) {
  final random = Random(DateTime.now().millisecondsSinceEpoch);
  final list = List<int>.generate(count, (_) => random.nextInt(count));

  final stopwatch = Stopwatch()..start();
  list.sort();
  stopwatch.stop();

  return stopwatch.elapsedMicroseconds / 1000.0;
}

// Modelo de dados para o teste de JSON
class MockPost {
  final int id;
  final String title;
  final String body;
  final int userId;

  MockPost(this.id, this.title, this.body, this.userId);

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'userId': userId,
  };

  factory MockPost.fromJson(Map<String, dynamic> json) {
    return MockPost(json['id'], json['title'], json['body'], json['userId']);
  }
}

// Função isolada para o parsing de JSON (para rodar no compute)
int _parseJsonTask(String jsonString) {
  // Decodifica a string para List<dynamic>
  final List<dynamic> parsed = jsonDecode(jsonString);
  // Converte cada item para o objeto MockPost
  final posts = parsed
      .map<MockPost>((json) => MockPost.fromJson(json))
      .toList();
  return posts.length;
}

class BenchmarkService {
  late Database _database;
  late String _appDirPath;

  Future<void> init() async {
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
  }

  Future<double> runSortBenchmark(int count) async {
    return await compute(_performSort, count);
  }

  Future<void> clearDb() async {
    await _database.delete('test_entries');
  }

  Future<double> runDbWriteBenchmark(int count) async {
    await clearDb();

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
    return stopwatch.elapsedMicroseconds / 1000.0;
  }

  Future<double> runDbReadBenchmark(int count) async {
    final countInDb =
        Sqflite.firstIntValue(
          await _database.rawQuery('SELECT COUNT(*) FROM test_entries'),
        ) ??
        0;

    if (countInDb < count) {
      await runDbWriteBenchmark(count);
    }

    final stopwatch = Stopwatch()..start();

    final List<Map<String, dynamic>> maps = await _database.query(
      'test_entries',
      limit: count,
    );

    stopwatch.stop();

    if (maps.length != count) {
      throw Exception("Erro: Lidos ${maps.length} de $count");
    }

    return stopwatch.elapsedMicroseconds / 1000.0;
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

  Future<double> runFileWriteBenchmark(int charCount) async {
    final data = _generateRandomString(charCount);
    final file = File(p.join(_appDirPath, 'benchmark_file_$charCount.txt'));

    final stopwatch = Stopwatch()..start();
    await file.writeAsString(data);
    stopwatch.stop();

    return stopwatch.elapsedMicroseconds / 1000.0;
  }

  Future<double> runFileReadBenchmark(int charCount) async {
    final file = File(p.join(_appDirPath, 'benchmark_file_$charCount.txt'));

    if (!await file.exists()) {
      await runFileWriteBenchmark(charCount);
    }

    final stopwatch = Stopwatch()..start();
    final data = await file.readAsString();
    stopwatch.stop();

    if (data.length != charCount) {
      throw Exception("Erro: Lidos ${data.length} de $charCount");
    }

    return stopwatch.elapsedMicroseconds / 1000.0;
  }

  Future<double> getMemoryUsage() async {
    // RSS (Resident Set Size) = Total Physical Memory used by the process
    return ProcessInfo.currentRss / (1024 * 1024);
  }

  Future<double> runNetworkBenchmark() async {
    final stopwatch = Stopwatch()..start();

    // Faz a requisição GET
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/photos'),
    );

    stopwatch.stop();

    if (response.statusCode == 200) {
      return stopwatch.elapsedMicroseconds / 1000.0;
    } else {
      throw Exception("Erro: ${response.statusCode}");
    }
  }

  Future<String> generateJsonData() async {
    return await compute((_) {
      final list = List.generate(
        10000,
        (i) => MockPost(i, "Título $i", "Corpo repetido $i", i),
      );
      return jsonEncode(list); // Usa dart:convert
    }, null);
  }

  Future<double> runJsonBenchmark(String jsonString) async {
    final stopwatch = Stopwatch()..start();
    await compute(_parseJsonTask, jsonString);
    stopwatch.stop();
    return stopwatch.elapsedMicroseconds / 1000.0;
  }
}
