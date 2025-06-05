import 'package:flutter/material.dart';
import 'ranking_screen.dart';
import 'quiz_screen.dart';
import 'login_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IPv4 Quiz Game'),
        centerTitle: true,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RankingScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text('Ver Ranking'),
            ),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QuizScreen(level: level)),
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