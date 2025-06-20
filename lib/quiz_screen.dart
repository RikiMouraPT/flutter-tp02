import 'package:flutter/material.dart';
import 'dart:math';
import 'database_helper.dart';

class QuizScreen extends StatefulWidget {
  final int level;
  final String username;
  final List<Question> questions;

  const QuizScreen({super.key, required this.level, required this.username, required this.questions});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  final dbHelper = DatabaseHelper.instance;

  int userScore = 0;
  int tempScore = 0;
  late List<Question> questions;
  int currentQuestionIndex = 0;
  late Question currentQuestion;
  bool showResult = false;
  int selectedOptionIndex = 0;

  void _answerQuestion(int option) {
    setState(() {
      showResult = true;
      // Guarda o índice da opção selecionada para no build destacar a resposta
      selectedOptionIndex = option;

      if (currentQuestion.options[option].isCorrect) {
        if (widget.level == 1) {
          tempScore = max(tempScore + 10, 0);
        } else if (widget.level == 2) {
          tempScore = max(tempScore + 20, 0);
        } else if (widget.level == 3) {
          tempScore = max(tempScore + 30, 0);
        }
            } else {
        if (widget.level == 1) {
          tempScore = max(tempScore - 5, 0);
        } else if (widget.level == 2) {
          tempScore = max(tempScore - 10, 0);
        } else if (widget.level == 3) {
          tempScore = max(tempScore - 15, 0);
        }
      }
    });
    //Delay to show the result
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        // Avança para a próxima pergunta e dá reset aos estados
        if (currentQuestionIndex < questions.length - 1) {
          currentQuestionIndex++;
          currentQuestion = questions[currentQuestionIndex];

          selectedOptionIndex = 0;
          showResult = false;
        } else {
          // Se não houver mais perguntas, mostra um dialog de conclusão e adiciona o score à db
          int newScore = userScore + tempScore;
          dbHelper.updateUserScore(widget.username, newScore);

          _showCompletionDialog();
        }
      });
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 5), () {
          Navigator.pop(context); // Fecha o dialog
          Navigator.pop(context); // Volta para o menu
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.blue.shade50,
          title: Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 32),
              SizedBox(width: 10),
              Text(
                'Quiz Concluído',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Parabéns!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 10),
              Text('A tua pontuação final é', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text(
                '$tempScore pontos',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              LinearProgressIndicator(
                value: widget.level == 1
                    ? tempScore / 30
                    : widget.level == 2
                    ? tempScore / 60
                    : tempScore / 90,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 10),
              Text(
                'Obrigado por jogares!',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    questions = widget.questions;
    currentQuestion = questions[0];
    _getCurrentUserScore();
  }

  void _getCurrentUserScore() async {
    final userMap = await dbHelper.queryUserByUsername(widget.username);
    if (userMap != null && userMap['score'] != null) {
      setState(() {
        userScore = userMap['score'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nível ${widget.level}'),
        actions: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Pontos: $tempScore',
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
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 20),
            Text(
              'Pergunta ${currentQuestionIndex + 1} de ${questions.length}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            // Pergunta
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  currentQuestion.text,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 30),
            // Lista de opções
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  String option = currentQuestion.options[index].text;
                  Color? buttonColor;

                  if (showResult) {
                    if (currentQuestion.options[index].isCorrect) {
                      buttonColor = Colors.green;
                    } else if (selectedOptionIndex == index &&
                        !currentQuestion.options[index].isCorrect) {
                      buttonColor = Colors.red;
                    }
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _answerQuestion(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.black87,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text(option, style: TextStyle(fontSize: 16)),
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
  final List<Option> options;

  Question({required this.text, required this.options});
}

class Option {
  final String text;
  final bool isCorrect;

  Option({required this.text, required this.isCorrect});
}
