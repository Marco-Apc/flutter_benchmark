# Flutter Benchmark

Um aplicativo Flutter para realizar benchmarks de operações de CPU, banco de dados e I/O (entrada/saída) de arquivo.

## Funcionalidades

Este aplicativo fornece uma interface simples para executar e medir o desempenho de operações comuns:

- **Testes de CPU**: Mede o tempo necessário para ordenar listas de inteiros de vários tamanhos usando o método `sort()` integrado do Dart (que utiliza o algoritmo Dual-Pivot Quicksort).
- **Testes de Banco de Dados**: Mede o tempo necessário para realizar operações de escrita e leitura em um banco de dados SQLite local usando o pacote `sqflite`.
- **Testes de I/O de Arquivo**: Mede o tempo necessário para escrever e ler dados em arquivos locais.
- **Monitor de Memória**: Exibe o uso atual de memória RAM (RSS) do aplicativo.
- **Testes de UI**: Inclui uma página de teste com uma lista longa (1000 itens) para verificar o desempenho de renderização e scroll.

## Arquitetura

O projeto foi refatorado para seguir uma arquitetura limpa e modular:
- **`lib/services/benchmark_service.dart`**: Contém toda a lógica de negócios e execução dos benchmarks (CPU, DB, I/O, Memória).
- **`lib/benchmark_page.dart`**: Camada de apresentação que interage com o usuário e exibe os resultados.
- **`lib/ui_test_page.dart`**: Página dedicada para testes de renderização de interface.

## Como Usar

1.  Clone o repositório.
2.  Execute `flutter pub get` para instalar as dependências.
3.  Execute o aplicativo em um dispositivo ou emulador.
4.  Clique nos botões para executar os respectivos testes de benchmark. Os resultados serão exibidos em milissegundos.


