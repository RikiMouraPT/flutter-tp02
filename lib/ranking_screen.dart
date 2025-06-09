import 'package:flutter/material.dart';
import 'database_helper.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  RankingScreenState createState() => RankingScreenState();
}

class RankingScreenState extends State<RankingScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> rankingData = [];

  @override
  void initState() {
    super.initState();
    loadRankingData();
  }

  void loadRankingData() async {
    List<Map<String, dynamic>> allRows = await dbHelper.queryAllRowsOrderedByScore();
    setState(() {
      rankingData = allRows;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh Ranking',
            onPressed: () {
              loadRankingData();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: rankingData.length,
                itemBuilder: (context, index) {
                  final user = rankingData[index];
                  return _buildRankingItem(
                    index + 1,
                    user['nome'] ?? 'N/A',
                    user['score'],
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
          backgroundColor: 
              position == 1
              ? const Color(0xFFFFD700) // Gold
              : position == 2
              ? const Color(0xFFC0C0C0) // Silver
              : position == 3
              ? Color(0xFFCD7F32) // Bronze
              : Colors.blue,
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
