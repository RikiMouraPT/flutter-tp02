import 'package:flutter/material.dart';
import 'ranking_screen.dart';
import 'quiz_screen.dart';
import 'login_screen.dart';
import 'dart:math';
import 'database_helper.dart';

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
  final dbHelper = DatabaseHelper.instance;
  Map<String, dynamic> user = {};

  Future<void> loadRankingData() async {
    Map<String, dynamic>? userData = await dbHelper.queryUserByUsername(widget.username);
    setState(() {
      if (userData != null) {
        user = userData;
      }
    });
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue),
    );
  }

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

  String getCompatibleSubMask(String ip) {
    Random rand = Random();
    // Máscaras válidas para cada octeto
    List<int> validMasks = [0, 128, 192, 224, 240, 248, 252, 254, 255];

    if (ip.startsWith('10.')) {
      // /8
      int maskValue = validMasks[rand.nextInt(validMasks.length)];
      return '255.$maskValue.0.0';
    } else if (ip.startsWith('172.')) {
      // /12
      int maskValue = validMasks[rand.nextInt(validMasks.length)];
      return '255.240.$maskValue.0';
    } else if (ip.startsWith('192.168.')) {
      // /16
      int maskValue = validMasks[rand.nextInt(validMasks.length)];
      return '255.255.255.$maskValue';
    } else {
      // fallback
      int maskValue = validMasks[rand.nextInt(validMasks.length)];
      return '255.255.255.$maskValue';
    }
  }

  String getCompatibleSuperMask(String ip) {
    Random rand = Random();
    // Máscaras válidas para super-redes (prefixos menores, ou seja, menos bits a 1)
    List<int> validMasks = [128, 192, 224, 240, 248, 252, 254];

    if (ip.startsWith('10.')) {
      int maskValue = validMasks[rand.nextInt(validMasks.length)];
      return '$maskValue.0.0.0';
    } else if (ip.startsWith('172.')) {
      int maskValue = validMasks[rand.nextInt(validMasks.length)];
      return '255.$maskValue.0.0';
    } else if (ip.startsWith('192.168.')) {
      int maskValue = validMasks[rand.nextInt(validMasks.length)];
      return '255.255.$maskValue.0';
    } else {
      int maskValue = validMasks[rand.nextInt(validMasks.length)];
      return '255.255.$maskValue.0';
    }
  }

  // Calcula o Network ID a partir do IP e da máscara e faz um AND por cada octeto
  String calculateNetworkId(String ip, String mask) {
    List<int> ipParts = ip.split('.').map(int.parse).toList();
    List<int> maskParts = mask.split('.').map(int.parse).toList();

    List<int> networkParts = List.generate(4, (i) => ipParts[i] & maskParts[i]);

    return networkParts.join('.');
  }

  String calculateBrodcastIp(String networkId, String mask) {
    List<int> networkParts = networkId.split('.').map(int.parse).toList();
    List<int> maskParts = mask.split('.').map(int.parse).toList();

    List<int> broadcastParts = List.generate(
      4,
      (i) => networkParts[i] | ~maskParts[i] & 255,
    );

    return broadcastParts.join('.');
  }

  List<Option> generateOptionsNetworkId(String correctNetworkId, int level) {
    final rand = Random();
    List<Option> optionsSet = [Option(text: correctNetworkId, isCorrect: true)];

    if(level == 1) {
      // Lista de Network IDs possíveis
      Set<String> possibleNetworkIdsSet = {
        '10.0.0.0',
        '172.16.0.0',
        '192.168.0.0',
      };
      possibleNetworkIdsSet.remove(correctNetworkId);
      List<String> possibleNetworkIds = possibleNetworkIdsSet.toList();

      // Adicionar os restantes Network IDs como opções incorretas
      for (int i = 0; i < possibleNetworkIds.length; i++) {
        optionsSet.add(Option(text: possibleNetworkIds[i], isCorrect: false));
      }
    }
    else 
    {
      for (int i = 0; i < 3; i++) {
        // Gera Network IDs aleatórios
        String randomIP = generatePrivateIP();
        String randomMask = level == 2
            ? getCompatibleSubMask(randomIP)
            : getCompatibleSuperMask(randomIP);
        String randomNetworkId = calculateNetworkId(randomIP, randomMask);
        optionsSet.add(Option(text: randomNetworkId, isCorrect: false));
      }
    }

    // Baralha todas as opções para que a correta não seja sempre a primeira
    optionsSet.shuffle(rand);

    return optionsSet;
  }

  List<Option> generateOptionsBroadcastIP(String broadcastAddress) {
    final rand = Random();
    List<Option> optionsList = [
      Option(text: broadcastAddress, isCorrect: true),
    ];

    for (int i = 0; i < 3; i++) {
      String randomIP = generatePrivateIP();
      optionsList.add(Option(text: randomIP, isCorrect: false));
    }

    optionsList.shuffle(rand);
    return optionsList;
  }

  bool sameSubnet(String ip1, String ip2, String mask) {
    String networkId1 = calculateNetworkId(ip1, mask);
    String networkId2 = calculateNetworkId(ip2, mask);

    if (networkId1 == networkId2) {
      return true;
    }
    return false;
  }

  // Method to generate a question
  List<Question> _generateQuestions(int level) {
    List<Question> questions = [];

    questions.add(_firstQuestion(level));
    questions.add(_secondQuestion(level));
    questions.add(_thirdQuestion(level));
    
    return questions;
  }

  //Metodo para questão de Network ID
  Question _firstQuestion(int level) {
    String ip = generatePrivateIP();

    String mask = level == 1
        ? getCompatibleMask(ip)
        : level == 2
        ? getCompatibleSubMask(ip)
        : getCompatibleSuperMask(ip);

    String networkId = calculateNetworkId(ip, mask);

    List<Option> options = generateOptionsNetworkId(networkId, level);

    String text =
        'Qual é o Network ID do endereço IP $ip com máscara de sub-rede $mask?';

    return Question(text: text, options: options);
  }

  //Metodo para questão de Broadcast Address
  Question _secondQuestion(int level) {
    String ip = generatePrivateIP();

    String mask = level == 1
        ? getCompatibleMask(ip)
        : level == 2
        ? getCompatibleSubMask(ip)
        : getCompatibleSuperMask(ip);

    String networkId = calculateNetworkId(ip, mask);

    String broadcastAddress = calculateBrodcastIp(networkId, mask);

    List<Option> options = generateOptionsBroadcastIP(broadcastAddress);

    String text =
        'Qual é o Broadcast Address do endereço IP $ip com máscara de sub-rede $mask?';

    return Question(text: text, options: options);
  }

  //Metodo para questão de Subnet Mask
  Question _thirdQuestion(int level) {
    String ip1 = generatePrivateIP();
    String ip2 = generatePrivateIP();

    String mask = level == 1
        ? getCompatibleMask(ip1)
        : level == 2
        ? getCompatibleSubMask(ip1)
        : getCompatibleSuperMask(ip1);

    bool isSame = sameSubnet(ip1, ip2, mask);

    String text =
        'Os endereços IP $ip1 e $ip2 estão no mesmo segmento de rede com máscara de sub-rede $mask?';

    return Question(
      text: text,
      options: [
        Option(text: isSame ? 'Sim' : 'Não', isCorrect: true),
        Option(text: isSame ? 'Não' : 'Sim', isCorrect: false),
      ],
    );
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
            onPressed: () async {
              await loadRankingData();
              _showMessage(
                context,
                'Bem-vindo, ${widget.username}! O teu score atual é: ${user['score']}',
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
