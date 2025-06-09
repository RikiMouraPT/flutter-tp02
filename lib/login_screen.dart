import 'package:flutter/material.dart';
import 'main.dart';
import 'ranking_screen.dart';
import 'database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final dbHelper = DatabaseHelper.instance;

  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage('Por favor, preencha todos os campos');
      return;
    }
    // Check if user exists
    Map<String, dynamic>? user = await dbHelper.queryUserByUsername(username);

    if (user != null ) {
      if (user['password'] == password) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(username: username, score: user['score']),
          ),
        );
        _showMessage('Login bem-sucedido!');
      }
      else {
        _showMessage('Senha incorreta. Tente novamente.');
      }
    } else {
      // Register new user
      await dbHelper.registerUser(username, password);
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(username: username, score: 0),
          ),
        );
      _showMessage('User registado com sucesso!');
    }
  }

  void _showMessage(String message) {
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
            icon: Icon(Icons.info_outline),
            tooltip: 'Sobre',
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'IPv4 Quiz Game',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(Icons.network_check_rounded, size: 50, color: Colors.blue),
                children: [
                  Text('Desenvolvido por Ricardo Moura e Vitor Rocha'),
                ],
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
            SizedBox(height: 40),
            Icon(Icons.network_check_rounded, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Bem-vindo ao IPv4 Quiz',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Teste os seus conhecimentos sobre redes IPv4',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _login(),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text('Entrar/Registar', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
