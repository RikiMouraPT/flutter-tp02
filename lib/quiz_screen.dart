import 'package:flutter/material.dart';
import 'dart:math';


class QuizScreen extends StatefulWidget {
  final int level;

  const QuizScreen({
    super.key, 
    required this.level
  });

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  int score = 0;
  List<Question> questions = [];
  String? selectedAnswer;
  bool showResult = false;
  bool isAnswered = false;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    questions = [];
    Random random = Random();

    for (int i = 0; i < 10; i++) {
      switch (widget.level) {
        case 1:
          questions.add(_generateLevel1Question(random));
          break;
        case 2:
          questions.add(_generateLevel2Question(random));
          break;
        case 3:
          questions.add(_generateLevel3Question(random));
          break;
      }
    }
  }

  Question _generateLevel1Question(Random random) {
    List<String> questionTypes = ['network_id', 'broadcast', 'same_network'];
    String type = questionTypes[random.nextInt(questionTypes.length)];

    switch (type) {
      case 'network_id':
        String ip =
            '${random.nextInt(256)}.${random.nextInt(256)}.${random.nextInt(256)}.${random.nextInt(256)}';
        int cidr = [8, 16, 24][random.nextInt(3)];
        String correctAnswer = _calculateNetworkId(ip, cidr);
        return Question(
          text: 'Qual é o Network ID do endereço IP $ip com máscara /$cidr?',
          correctAnswer: correctAnswer,
          options: _generateIPOptions(correctAnswer),
        );

      case 'broadcast':
        String ip =
            '${random.nextInt(256)}.${random.nextInt(256)}.${random.nextInt(256)}.${random.nextInt(256)}';
        int cidr = [8, 16, 24][random.nextInt(3)];
        String correctAnswer = _calculateBroadcast(ip, cidr);
        return Question(
          text: 'Qual é o Broadcast do endereço IP $ip com máscara /$cidr?',
          correctAnswer: correctAnswer,
          options: _generateIPOptions(correctAnswer),
        );

      default:
        String ip1 = '172.16.${random.nextInt(256)}.${random.nextInt(256)}';
        String ip2 = '172.16.${random.nextInt(256)}.${random.nextInt(256)}';
        int cidr = 16;
        bool sameNetwork = _areInSameNetwork(ip1, ip2, cidr);
        return Question(
          text:
              'Os endereços IP $ip1 e $ip2 estão no mesmo segmento de rede com máscara /$cidr?',
          correctAnswer: sameNetwork ? 'Sim' : 'Não',
          options: ['Sim', 'Não'],
        );
    }
  }

  Question _generateLevel2Question(Random random) {
    String ip = '192.168.${random.nextInt(256)}.${random.nextInt(256)}';
    int cidr = 24 + random.nextInt(8); // /24 to /31
    String correctAnswer = _calculateNetworkId(ip, cidr);

    return Question(
      text:
          'Qual é o Network ID do endereço IP $ip com máscara de sub-rede /$cidr?',
      correctAnswer: correctAnswer,
      options: _generateIPOptions(correctAnswer),
    );
  }

  Question _generateLevel3Question(Random random) {
    String ip =
        '${random.nextInt(256)}.${random.nextInt(256)}.${random.nextInt(256)}.${random.nextInt(256)}';
    int cidr = random.nextInt(24); // /0 to /23
    String correctAnswer = _calculateNetworkId(ip, cidr);

    return Question(
      text:
          'Qual é o Network ID do endereço IP $ip com máscara de super-rede /$cidr?',
      correctAnswer: correctAnswer,
      options: _generateIPOptions(correctAnswer),
    );
  }

  String _calculateNetworkId(String ip, int cidr) {
    List<int> ipParts = ip.split('.').map(int.parse).toList();
    int mask = (0xffffffff << (32 - cidr)) & 0xffffffff;

    int ipInt =
        (ipParts[0] << 24) |
        (ipParts[1] << 16) |
        (ipParts[2] << 8) |
        ipParts[3];
    int networkInt = ipInt & mask;

    return '${(networkInt >> 24) & 0xff}.${(networkInt >> 16) & 0xff}.${(networkInt >> 8) & 0xff}.${networkInt & 0xff}';
  }

  String _calculateBroadcast(String ip, int cidr) {
    List<int> ipParts = ip.split('.').map(int.parse).toList();
    int mask = (0xffffffff << (32 - cidr)) & 0xffffffff;

    int ipInt =
        (ipParts[0] << 24) |
        (ipParts[1] << 16) |
        (ipParts[2] << 8) |
        ipParts[3];
    int networkInt = ipInt & mask;
    int broadcastInt = networkInt | (~mask & 0xffffffff);

    return '${(broadcastInt >> 24) & 0xff}.${(broadcastInt >> 16) & 0xff}.${(broadcastInt >> 8) & 0xff}.${broadcastInt & 0xff}';
  }

  bool _areInSameNetwork(String ip1, String ip2, int cidr) {
    String network1 = _calculateNetworkId(ip1, cidr);
    String network2 = _calculateNetworkId(ip2, cidr);
    return network1 == network2;
  }

  List<String> _generateIPOptions(String correctAnswer) {
    List<String> options = [correctAnswer];
    Random random = Random();

    while (options.length < 4) {
      String wrongAnswer =
          '${random.nextInt(256)}.${random.nextInt(256)}.${random.nextInt(256)}.${random.nextInt(256)}';
      if (!options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }

    options.shuffle();
    return options;
  }

  void _answerQuestion(String answer) {
    if (isAnswered) return;

    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
      showResult = true;

      if (answer == questions[currentQuestion].correctAnswer) {
        score += _getPointsForLevel();
      }
    });

    Future.delayed(Duration(seconds: 2), () {
      _nextQuestion();
    });
  }

  int _getPointsForLevel() {
    switch (widget.level) {
      case 1:
        return 10;
      case 2:
        return 20;
      case 3:
        return 30;
      default:
        return 10;
    }
  }

  void _nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        showResult = false;
        isAnswered = false;
      });
    } else {
      _showFinalScore();
    }
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Concluído!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pontuação Final: $score'),
              SizedBox(height: 10),
              Text('Nível: ${widget.level}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Voltar ao Menu'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentQuestion = 0;
                  score = 0;
                  selectedAnswer = null;
                  showResult = false;
                  isAnswered = false;
                });
                _generateQuestions();
              },
              child: Text('Jogar Novamente'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Carregando...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Question currentQ = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: Text('Nível ${widget.level}'),
        actions: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Pontos: $score',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentQuestion + 1) / questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 20),
            Text(
              'Pergunta ${currentQuestion + 1} de ${questions.length}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  currentQ.text,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: currentQ.options.length,
                itemBuilder: (context, index) {
                  String option = currentQ.options[index];
                  Color? buttonColor;

                  if (showResult) {
                    if (option == currentQ.correctAnswer) {
                      buttonColor = Colors.green;
                    } else if (option == selectedAnswer &&
                        option != currentQ.correctAnswer) {
                      buttonColor = Colors.red;
                    }
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _answerQuestion(option),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text(option, style: TextStyle(fontSize: 16)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: buttonColor != null
                              ? Colors.white
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Question {
  final String text;
  final String correctAnswer;
  final List<String> options;

  Question({
    required this.text,
    required this.correctAnswer,
    required this.options,
  });
}