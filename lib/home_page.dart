import 'package:flutter/material.dart';
import 'quiz_page.dart';

class MyHomePage extends StatefulWidget {
  static const routeName = '/home';
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _errors = 0;
  List<Map<String, int>> tentativas = [];

  void _recalcularTotais() {
    _counter = tentativas.fold(0, (soma, t) => soma + (t['acertos'] ?? 0));
    _errors = tentativas.fold(0, (soma, t) => soma + (t['erros'] ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Quiz App')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 80),
            const SizedBox(height: 16),
            const Text(
              'Flutter Quiz App',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Acertos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  '$_counter',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cancel, color: Colors.red, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Erros:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  '$_errors',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (tentativas.isNotEmpty) ...[
              const Text(
                'Tentativas anteriores:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tentativas.length,
                  itemBuilder: (context, i) {
                    final t = tentativas[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 24,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Tentativa ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '#${i + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 18,
                            ),
                            Text(
                              ' ${t['acertos']} ',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 18,
                            ),
                            Text(
                              ' ${t['erros']}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  final result = await Navigator.of(context).pushNamed(
                    QuizPage.routeName,
                    arguments: {'acertos': 0, 'erros': 0},
                  );
                  if (!mounted) return;
                  if (result is Map) {
                    setState(() {
                      tentativas.insert(0, {
                        'acertos': (result['acertos'] ?? 0) as int,
                        'erros': (result['erros'] ?? 0) as int,
                      });
                      if (tentativas.length > 5) {
                        tentativas = tentativas.sublist(0, 5);
                      }
                      _recalcularTotais();
                    });
                  }
                },
                child: const Text('Iniciar Quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
