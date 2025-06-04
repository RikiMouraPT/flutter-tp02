import 'package:flutter/material.dart';
import 'database_helper.dart';


class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {

  List<Map<String, dynamic>> _rankingData = [];

  @override
  void initState() async {
    super.initState();
    final dbHelper = DatabaseHelper.instance;
    
    List<Map<String, dynamic>> users =  await dbHelper.queryAllRowsOrderedByScore();

    setState(() {
      _rankingData = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ranking')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
                child: ListView.builder(
                itemCount: _rankingData.length,
                itemBuilder: (context, index) {
                  final user = _rankingData[index];
                  return _buildRankingItem(
                    index + 1,
                    user['name'] ?? 'Sem Nome',
                    user['score'] ?? 0,
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingItem(int position, String name, int score) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: position <= 3 ? Colors.yellow : Colors.grey,
          child: Text('$position'),
        ),
        title: Text(name),
        trailing: Text(
          '$score pts',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
