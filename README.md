# Flutter Benchmark

Um aplicativo Flutter para realizar benchmarks de operações de CPU, banco de dados e I/O (entrada/saída) de arquivo.

## Funcionalidades

Este aplicativo fornece uma interface simples para executar e medir o desempenho de operações comuns:

- **Testes de CPU**: Mede o tempo necessário para ordenar listas de inteiros de vários tamanhos usando o método `sort()` integrado do Dart (que utiliza o algoritmo Dual-Pivot Quicksort).
- **Testes de Banco de Dados**: Mede o tempo necessário para realizar operações de escrita e leitura em um banco de dados SQLite local usando o pacote `sqflite`.
- **Testes de I/O de Arquivo**: Mede o tempo necessário para escrever e ler dados em arquivos locais.

## Como Usar

1.  Clone o repositório.
2.  Execute `flutter pub get` para instalar as dependências.
3.  Execute o aplicativo em um dispositivo ou emulador.
4.  Clique nos botões para executar os respectivos testes de benchmark. Os resultados serão exibidos em milissegundos.


