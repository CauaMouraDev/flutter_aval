# Flutter Quiz App

Um aplicativo de quiz simples desenvolvido em Flutter, com visual moderno e componentes nativos. O app possui três telas principais: Splash, Login (visual) e Quiz.

## Descrição

- **SplashScreen:** Tela inicial com logo e nome do app, transição automática para o login.
- **LoginPage:** Tela de login visual (não realiza autenticação real), apenas para navegação.
- **QuizPage:** Quiz de conhecimentos gerais com perguntas de múltipla escolha. Mostra contadores de acertos (verde) e erros (vermelho) ao final.
- **Tela Principal:** Exibe contadores coloridos de acertos/erros e botão para iniciar o quiz.

## Funcionalidades

### Navegação entre telas por rotas nomeadas

O app utiliza rotas nomeadas para facilitar a navegação entre as telas principais:

```dart
MaterialApp(
  initialRoute: SplashScreen.routeName,
  routes: {
    SplashScreen.routeName: (context) => const SplashScreen(),
    LoginPage.routeName: (context) => const LoginPage(),
    QuizPage.routeName: (context) => const QuizPage(),
    MyHomePage.routeName: (context) => const MyHomePage(),
  },
)
```

---

### SplashScreen: tela inicial com transição automática

Exibe a logo e o nome do app por 2 segundos e navega para o login:

```dart
class SplashScreen extends StatelessWidget {
  static const routeName = '/splash';
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
    });
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            FlutterLogo(size: 100),
            SizedBox(height: 24),
            Text(
              'Flutter Quiz App',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### LoginPage: autenticação com Firebase

Permite login/cadastro com email e senha, usando Firebase Auth e registra o login no Firestore:

```dart
class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  const LoginPage({super.key});
  // ...
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // ...
  Future<void> login() async {
    setState(() { loading = true; errorMessage = null; });
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseFirestore.instance.collection('usuarios').doc(email).set({
        'email': email,
        'ultimo_login': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      setState(() { errorMessage = e.message ?? 'Erro ao fazer login.'; });
    } finally {
      if (mounted) setState(() { loading = false; });
    }
  }
  // ...
}
```

---

### Tela Principal (`MyHomePage`): contadores, tentativas e início do quiz

Exibe contadores de acertos/erros, tentativas anteriores e botão para iniciar o quiz:

```dart
class MyHomePage extends StatefulWidget {
  static const routeName = '/home';
  const MyHomePage({super.key});
  // ...
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
            // ...
            ElevatedButton(
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
            // ...
          ],
        ),
      ),
    );
  }
}
```

---

### QuizPage: perguntas, feedback colorido e botão amarelo

Mostra perguntas de múltipla escolha, feedback colorido (verde para acerto, vermelho para erro), botão "Próxima" ou "Finalizar" em amarelo claro. Ao finalizar, exibe resumo e retorna para a tela principal:

```dart
class QuizPage extends StatefulWidget {
  static const routeName = '/quiz';
  const QuizPage({super.key});
  // ...
}

class _QuizPageState extends State<QuizPage> {
  int qIndex = 0;
  int acertos = 0;
  int erros = 0;
  int? selecionada;
  bool respondeu = false;

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
        builder: (context) => AlertDialog(
          title: const Text('Quiz finalizado!'),
          content: Text('Acertos: $acertos\nErros: $erros'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop({'acertos': acertos, 'erros': erros});
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
            Text('Pergunta ${qIndex + 1} de ${quizQuestions.length}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text(pergunta, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
              child: Text(qIndex < quizQuestions.length - 1 ? 'Próxima' : 'Finalizar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Visual moderno

O app utiliza gradiente de fundo, cards centralizados, ícones coloridos e botões grandes para uma experiência agradável:

```dart
Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.white, Color(0xFFEDE7F6)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ),
  child: Center(
    child: Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      // ...
    ),
  ),
)
```

---

### Estrutura e dependências

- O código agora está organizado em vários arquivos na pasta `lib/`:
  - `main.dart`: inicialização do app, rotas e tema.
  - `splash_screen.dart`: tela de splash.
  - `login_page.dart`: tela de login (com autenticação Firebase).
  - `home_page.dart`: tela principal com contadores e tentativas.
  - `quiz_page.dart`: tela do quiz e lógica das perguntas.
- O app utiliza Firebase Auth e Firestore para autenticação e registro de login.
- As telas e lógicas estão separadas para facilitar manutenção e entendimento.

## Instalação

1. **Pré-requisitos:**
   - Flutter instalado ([instruções oficiais](https://docs.flutter.dev/get-started/install))
   - SDK do Dart
   - Conta e projeto no Firebase (com Auth e Firestore configurados)
2. **Clone o repositório:**
   ```sh
   git clone <url-do-repositorio>
   ```
3. **Acesse a pasta do projeto:**
   ```sh
   cd flutter_aval
   ```
4. **Instale as dependências:**
   ```sh
   flutter pub get
   ```
5. **Configure o Firebase:**
   - Adicione o arquivo `google-services.json` (Android) e/ou `GoogleService-Info.plist` (iOS) nas pastas correspondentes.
   - Verifique se o arquivo `firebase_options.dart` está presente (ou gere com o FlutterFire CLI).

## Execução

1. **Execute o app em um emulador ou dispositivo físico:**

   ```sh
   flutter run
   ```

2. **Navegue pelas telas:**
   - Splash → Login (Firebase) → Tela Principal → Quiz

---

Desenvolvido para fins de avaliação e estudo. Agora com autenticação real e código organizado em múltiplos arquivos!
