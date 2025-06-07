import 'package:flutter/material.dart';
import 'ranking_screen.dart';
import 'quiz_screen.dart';
import 'login_screen.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'IPv4 Quiz Game', home: LoginScreen());
  }
}

class HomeScreen extends StatefulWidget {
  final String username;
  final int score;

  const HomeScreen({super.key, required this.username, required this.score});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue),
    );
  }
  
  List<Question> questions = [];


  String generatePrivateIP() {
  final rand = Random();
  int range = rand.nextInt(3);

  switch (range) {
    case 0: // 10.0.0.0/8
      return '10.${rand.nextInt(256)}.${rand.nextInt(256)}.${rand.nextInt(256)}';
    case 1: // 172.16.0.0 - 172.31.255.255 (/12)
      return '172.${16 + rand.nextInt(16)}.${rand.nextInt(256)}.${rand.nextInt(256)}';
    case 2: // 192.168.0.0/16
      return '192.168.${rand.nextInt(256)}.${rand.nextInt(256)}';
    default:
      return '192.168.1.1'; // fallback
  }
}

String getCompatibleMask(String ip) {
  if (ip.startsWith('10.')) {
    return '255.0.0.0'; // /8
  } else if (ip.startsWith('172.')) {
    return '255.240.0.0'; // /12
  } else if (ip.startsWith('192.168.')) {
    return '255.255.0.0'; // /16
  } else {
    return '255.255.255.0'; // fallback
  }
}

String calculateNetworkId(String ip, String mask) {
  List<int> ipParts = ip.split('.').map(int.parse).toList();
  List<int> maskParts = mask.split('.').map(int.parse).toList();

  List<int> networkParts = List.generate(4, (i) => ipParts[i] & maskParts[i]);

  return networkParts.join('.');
}



List<Option> generateOptions(String correctNetworkId) {
  final rand = Random();
  List<Option> optionsSet = [Option(text: correctNetworkId, isCorrect: true)];
  
  // Lista de Network IDs possíveis (mais alguns inventados para variedade)
  List<String> possibleNetworkIds = [
    '10.0.0.0',      // Classe A privada
    '172.16.0.0',    // Classe B privada  
    '192.168.0.0',   // Classe C privada
    '192.168.1.0',   // Variação comum
    '10.1.0.0',      // Variação de Classe A
    '172.17.0.0',    // Variação de Classe B
    '192.168.10.0',  // Outra variação comum
    '10.10.0.0',     // Mais uma variação
    '172.20.0.0'     // Mais uma variação
  ];
  
  // Remove o Network ID correto da lista
  possibleNetworkIds.removeWhere((id) => id == correctNetworkId);
  
  // Embaralha a lista
  possibleNetworkIds.shuffle(rand);
  
  // Adiciona os primeiros 3 como opções incorretas
  for (int i = 0; i < 3 && i < possibleNetworkIds.length; i++) {
    optionsSet.add(Option(text: possibleNetworkIds[i], isCorrect: false));
  }
  
  // Embaralha todas as opções para que a correta não seja sempre a primeira
  optionsSet.shuffle(rand);
  
  return optionsSet;
}



  // Method to generate a question

  List<Question>_generateQuestions(int level) {
    switch (level) {
      case 1:
        String ip = generatePrivateIP();
        String mask = getCompatibleMask(ip);
        String networkId = calculateNetworkId(ip, mask);
        List<Option> options = generateOptions(networkId);

        String text =
              'Qual é o Network ID do endereço IP $ip com máscara de sub-rede $mask?';
        questions = [
          Question(
            text: text,
            options: options,
          ),
        ];
        // ver se se pode manter os mesmos métodos para a questão 2 de broadcast

        
        return questions;
      default:
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IPv4 Quiz Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () {
              _showMessage(
                context,
                'Bem-vindo, ${widget.username}! O teu score atual é: ${widget.score}',
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.leaderboard),
            tooltip: 'Ranking',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RankingScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AnimatedSwitcher(duration: Duration(seconds: 1)),
            SizedBox(height: 40),
            Icon(Icons.quiz_rounded, size: 100, color: Colors.blue.shade400),
            SizedBox(height: 20),
            Text(
              'Escolha o nível de dificuldade',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            _buildLevelButton(
              context,
              'Nível 1',
              'Endereços IPv4 /8, /16 e /24',
              Colors.green,
              1,
            ),
            SizedBox(height: 20),
            _buildLevelButton(
              context,
              'Nível 2',
              'Sub-redes',
              Colors.orange,
              2,
            ),
            SizedBox(height: 20),
            _buildLevelButton(context, 'Nível 3', 'Super-redes', Colors.red, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    int level,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Generate questions for the selected level before navigation
          List<Question> generatedQuestions = _generateQuestions(level);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(
                level: level,
                username: widget.username,
                questions: generatedQuestions,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(subtitle, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
