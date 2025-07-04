import 'package:flutter/material.dart';

final List<List> quizQuestions = [
  [
    'O que é o Flutter?',
    [
      'Um framework para desenvolvimento web',
      'Um framework para desenvolvimento mobile, web e desktop',
      'Uma linguagem de programação',
      'Um banco de dados',
    ],
    1,
  ],
  [
    'Qual linguagem é utilizada para programar no Flutter?',
    ['Java', 'Kotlin', 'Dart', 'Swift'],
    2,
  ],
  [
    'Qual comando compila e executa um app Flutter?',
    ['flutter build', 'flutter run', 'flutter start', 'flutter compile'],
    1,
  ],
  [
    'Qual widget é usado para layouts em coluna?',
    ['Row', 'Stack', 'Column', 'Container'],
    2,
  ],
  [
    'Como se chama o processo de atualizar o app sem perder estado?',
    ['Hot reload', 'Cold restart', 'Full rebuild', 'Stateful update'],
    0,
  ],
];

class QuizPage extends StatefulWidget {
  static const routeName = '/quiz';
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int qIndex = 0;
  int acertos = 0;
  int erros = 0;
  int? selecionada;
  bool respondeu = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      setState(() {
        acertos = args['acertos'] ?? 0;
        erros = args['erros'] ?? 0;
      });
    }
  }

  void responder(int i) {
    if (respondeu) return;
    setState(() {
      selecionada = i;
      respondeu = true;
      if (i == quizQuestions[qIndex][2]) {
        acertos++;
      } else {
        erros++;
      }
    });
  }

  Future<void> proxima() async {
    if (qIndex < quizQuestions.length - 1) {
      setState(() {
        qIndex++;
        selecionada = null;
        respondeu = false;
      });
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Quiz finalizado!'),
              content: Text('Acertos: $acertos\nErros: $erros'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(
                      context,
                    ).pop({'acertos': acertos, 'erros': erros});
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pergunta = quizQuestions[qIndex][0] as String;
    final opcoes = quizQuestions[qIndex][1] as List<String>;
    final correta = quizQuestions[qIndex][2] as int;
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Flutter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pergunta ${qIndex + 1} de ${quizQuestions.length}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              pergunta,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Column(
              children: List.generate(opcoes.length, (i) {
                Color? cor;
                if (respondeu) {
                  if (i == correta) {
                    cor = Colors.green;
                  } else if (selecionada == i) {
                    cor = Colors.red;
                  }
                }
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: cor),
                    onPressed: respondeu ? null : () => responder(i),
                    child: Text(opcoes[i]),
                  ),
                );
              }),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: respondeu ? proxima : null,
              child: Text(
                qIndex < quizQuestions.length - 1 ? 'Próxima' : 'Finalizar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
