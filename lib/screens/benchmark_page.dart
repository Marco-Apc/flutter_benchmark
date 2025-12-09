import 'package:flutter/material.dart';
import '../services/benchmark_service.dart';
import 'ui_test_page.dart';

class BenchmarkPage extends StatefulWidget {
  const BenchmarkPage({super.key});

  @override
  State<BenchmarkPage> createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends State<BenchmarkPage> {
  final Map<String, String> _results = {};
  final _benchmarkService = BenchmarkService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _benchmarkService.init();
    if (mounted) setState(() {});
  }

  Future<void> _runBenchmark(
    String key,
    Future<double> Function() benchmark,
  ) async {
    setState(() => _results[key] = "Rodando...");
    try {
      final time = await benchmark();
      if (mounted) {
        setState(() => _results[key] = "${time.toStringAsFixed(3)} ms");
      }
    } catch (e) {
      if (mounted) setState(() => _results[key] = "Erro: $e");
    }
  }

  Future<void> _readCurrentMemory(String key) async {
    setState(() => _results[key] = "Lendo...");
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final memoryMb = await _benchmarkService.getMemoryUsage();
      if (mounted) {
        setState(
          () => _results[key] = "RSS: ${memoryMb.toStringAsFixed(1)} MB",
        );
      }
    } catch (e) {
      if (mounted) setState(() => _results[key] = "Erro: $e");
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
              () => _runBenchmark(
                'sort10k',
                () => _benchmarkService.runSortBenchmark(10000),
              ),
            ),
            _buildTestRow(
              'sort100k',
              'Sort 100,000',
              () => _runBenchmark(
                'sort100k',
                () => _benchmarkService.runSortBenchmark(100000),
              ),
            ),
            _buildTestRow(
              'sort1M',
              'Sort 1,000,000',
              () => _runBenchmark(
                'sort1M',
                () => _benchmarkService.runSortBenchmark(1000000),
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Testes de Banco de Dados (SQLite)'),
            _buildTestRow(
              'dbWrite100',
              'Write 100',
              () => _runBenchmark(
                'dbWrite100',
                () => _benchmarkService.runDbWriteBenchmark(100),
              ),
            ),
            _buildTestRow(
              'dbWrite500',
              'Write 500',
              () => _runBenchmark(
                'dbWrite500',
                () => _benchmarkService.runDbWriteBenchmark(500),
              ),
            ),
            _buildTestRow(
              'dbWrite1k',
              'Write 1,000',
              () => _runBenchmark(
                'dbWrite1k',
                () => _benchmarkService.runDbWriteBenchmark(1000),
              ),
            ),
            const SizedBox(height: 8),
            _buildTestRow(
              'dbRead100',
              'Read 100',
              () => _runBenchmark(
                'dbRead100',
                () => _benchmarkService.runDbReadBenchmark(100),
              ),
            ),
            _buildTestRow(
              'dbRead500',
              'Read 500',
              () => _runBenchmark(
                'dbRead500',
                () => _benchmarkService.runDbReadBenchmark(500),
              ),
            ),
            _buildTestRow(
              'dbRead1k',
              'Read 1,000',
              () => _runBenchmark(
                'dbRead1k',
                () => _benchmarkService.runDbReadBenchmark(1000),
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Testes de Arquivo (I/O)'),
            _buildTestRow(
              'fileWrite1k',
              'Write 1,000',
              () => _runBenchmark(
                'fileWrite1k',
                () => _benchmarkService.runFileWriteBenchmark(1000),
              ),
            ),
            _buildTestRow(
              'fileWrite10k',
              'Write 10,000',
              () => _runBenchmark(
                'fileWrite10k',
                () => _benchmarkService.runFileWriteBenchmark(10000),
              ),
            ),
            _buildTestRow(
              'fileWrite100k',
              'Write 100,000',
              () => _runBenchmark(
                'fileWrite100k',
                () => _benchmarkService.runFileWriteBenchmark(100000),
              ),
            ),
            const SizedBox(height: 8),
            _buildTestRow(
              'fileRead1k',
              'Read 1,000',
              () => _runBenchmark(
                'fileRead1k',
                () => _benchmarkService.runFileReadBenchmark(1000),
              ),
            ),
            _buildTestRow(
              'fileRead10k',
              'Read 10,000',
              () => _runBenchmark(
                'fileRead10k',
                () => _benchmarkService.runFileReadBenchmark(10000),
              ),
            ),
            _buildTestRow(
              'fileRead100k',
              'Read 100,000',
              () => _runBenchmark(
                'fileRead100k',
                () => _benchmarkService.runFileReadBenchmark(100000),
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Monitor de Memória RAM'),
            _buildTestRow(
              'memory',
              'Ler Memória Atual',
              () => _readCurrentMemory('memory'),
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Testes de Rede e JSON'),
            _buildTestRow(
              'network',
              'GET 5k Photos (Net)',
              () => _runNetworkTest('network'),
            ),
            _buildTestRow(
              'json',
              'Parse 10k Items (CPU)',
              () => _runJsonTest('json'),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Testes de UI (Renderização)'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UiTestPage(),
                          ),
                        );
                      },
                      child: const Text('Abrir Lista (1k Itens)'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Medir com DevTools',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Teste de Rede: Baixa 5000 itens do JSONPlaceholder
  Future<void> _runNetworkTest(String key) async {
    setState(() => _results[key] = "Baixando...");
    try {
      final time = await _benchmarkService.runNetworkBenchmark();
      if (mounted) {
        setState(() => _results[key] = "${time.toStringAsFixed(3)} ms");
      }
    } catch (e) {
      if (mounted) setState(() => _results[key] = "Erro Net");
    }
  }

  /// Teste de JSON: Gera string e mede o parsing
  Future<void> _runJsonTest(String key) async {
    setState(() => _results[key] = "Gerando...");

    // 1. Preparação: Gera String JSON gigante (fora do timer)
    final jsonString = await _benchmarkService.generateJsonData();

    if (!mounted) return;
    setState(() => _results[key] = "Parsing...");

    // 2. Teste: Mede o tempo de parsing (String -> List<Object>)
    try {
      final time = await _benchmarkService.runJsonBenchmark(jsonString);
      if (mounted) {
        setState(() => _results[key] = "${time.toStringAsFixed(3)} ms");
      }
    } catch (e) {
      if (mounted) setState(() => _results[key] = "Erro JSON");
    }
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
