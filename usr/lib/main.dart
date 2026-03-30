import 'package:flutter/material.dart';

void main() {
  runApp(const DijkstraApp());
}

class DijkstraApp extends StatelessWidget {
  const DijkstraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algorytm Dijkstry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Zapewnienie bezpieczeństwa routingu
      initialRoute: '/',
      routes: {
        '/': (context) => const DijkstraHomePage(),
      },
    );
  }
}

class DijkstraHomePage extends StatefulWidget {
  const DijkstraHomePage({super.key});

  @override
  State<DijkstraHomePage> createState() => _DijkstraHomePageState();
}

class _DijkstraHomePageState extends State<DijkstraHomePage> {
  // Wartość reprezentująca brak połączenia (nieskończoność)
  static const int INF = 999999;

  // Przykładowa macierz odległości (analogiczna do tej z Excela).
  // Zastąp te wartości swoimi danymi z pliku "szablon 2".
  // 0 oznacza odległość do samego siebie, INF oznacza brak bezpośredniej drogi.
  final List<List<int>> matrix = [
    [0, 4, 2, INF, INF, INF],
    [4, 0, 1, 5, INF, INF],
    [2, 1, 0, 8, 10, INF],
    [INF, 5, 8, 0, 2, 6],
    [INF, INF, 10, 2, 0, 3],
    [INF, INF, INF, 6, 3, 0],
  ];

  // Nazwy węzłów (np. miasta, punkty)
  final List<String> nodeNames = ['A', 'B', 'C', 'D', 'E', 'F'];

  int selectedStart = 0;
  int selectedEnd = 5;

  String resultText = "Wybierz węzły i kliknij 'Oblicz'";

  // Implementacja algorytmu Dijkstry
  void calculateDijkstra() {
    int n = matrix.length;
    List<int> distances = List.filled(n, INF);
    List<bool> visited = List.filled(n, false);
    List<int> previous = List.filled(n, -1);

    // Dystans do węzła początkowego to 0
    distances[selectedStart] = 0;

    for (int i = 0; i < n - 1; i++) {
      int minDistance = INF;
      int minIndex = -1;

      // Znajdź węzeł o najmniejszym dystansie, który nie był jeszcze odwiedzony
      for (int v = 0; v < n; v++) {
        if (!visited[v] && distances[v] <= minDistance) {
          minDistance = distances[v];
          minIndex = v;
        }
      }

      if (minIndex == -1) break;
      
      // Oznacz węzeł jako odwiedzony
      visited[minIndex] = true;

      // Aktualizuj dystanse do sąsiadów
      for (int v = 0; v < n; v++) {
        if (!visited[v] && 
            matrix[minIndex][v] != 0 && 
            matrix[minIndex][v] != INF &&
            distances[minIndex] != INF &&
            distances[minIndex] + matrix[minIndex][v] < distances[v]) {
          distances[v] = distances[minIndex] + matrix[minIndex][v];
          previous[v] = minIndex;
        }
      }
    }

    // Jeśli nie ma trasy
    if (distances[selectedEnd] == INF) {
      setState(() {
        resultText = "Brak trasy pomiędzy ${nodeNames[selectedStart]} a ${nodeNames[selectedEnd]}";
      });
      return;
    }

    // Odtwarzanie najkrótszej ścieżki
    List<int> path = [];
    int current = selectedEnd;
    while (current != -1) {
      path.insert(0, current);
      current = previous[current];
    }

    String pathString = path.map((idx) => nodeNames[idx]).join(" -> ");
    setState(() {
      resultText = "Najkrótsza trasa:\n$pathString\n\nŁączny koszt (odległość): ${distances[selectedEnd]}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Algorytm Dijkstry'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Macierz odległości (Podgląd danych):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Zmień zmienną `matrix` w kodzie, aby wstawić dokładne dane ze swojego pliku Excel.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // Tabela wyświetlająca macierz
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Card(
                elevation: 2,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                  columns: [
                    const DataColumn(label: Text('Węzeł', style: TextStyle(fontWeight: FontWeight.bold))),
                    ...nodeNames.map((name) => DataColumn(label: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)))),
                  ],
                  rows: List.generate(matrix.length, (i) {
                    return DataRow(
                      cells: [
                        DataCell(Text(nodeNames[i], style: const TextStyle(fontWeight: FontWeight.bold))),
                        ...List.generate(matrix[i].length, (j) {
                          final val = matrix[i][j];
                          return DataCell(Text(val == INF ? '∞' : val.toString()));
                        }),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Wyznaczanie najkrótszej trasy:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 20,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Punkt startowy: '),
                    DropdownButton<int>(
                      value: selectedStart,
                      items: List.generate(nodeNames.length, (index) {
                        return DropdownMenuItem(
                          value: index,
                          child: Text(nodeNames[index]),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedStart = val);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Punkt końcowy: '),
                    DropdownButton<int>(
                      value: selectedEnd,
                      items: List.generate(nodeNames.length, (index) {
                        return DropdownMenuItem(
                          value: index,
                          child: Text(nodeNames[index]),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedEnd = val);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: calculateDijkstra,
                icon: const Icon(Icons.route),
                label: const Text('Oblicz najkrótszą trasę', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wynik:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resultText,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
