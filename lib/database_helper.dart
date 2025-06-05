import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "tp02sqlite.db";
  static final _databaseVersion = 1;
  static final table = 'Users';
  static final columnId = 'id';
  static final columnName = 'nome';
  static final columnPassword = 'password';
  static final columnScore = 'score';

  // Classe que usa padrão singleton
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  // Abre a base de dados e cria-a (se não existir)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL para criar a tabela (se não existir)
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnName TEXT NOT NULL UNIQUE,
      $columnPassword TEXT NOT NULL, -- Em produção, armazena passwords com hash!
      $columnScore INTEGER DEFAULT 0
      )
      ''');
  }

  // --- MÉTODOS CRUD ---

  // Método para registar um novo utilizador
  Future<int?> registerUser(String username, String password) async {
    Database db = await instance.database;
    try {
      // NOTA: Em produção, a password DEVE ser "hashed" antes de ser guardada.
      return await db.insert(table, {
        columnName: username,
        columnPassword: password,
        columnScore: 0,
      });
    } catch (e) {
      // Ex: Username já existe devido à constraint UNIQUE
      return null;
    }
  }

  // Método para consultar todos os dados ordenados por score (para o Ranking)
  Future<List<Map<String, dynamic>>> queryAllRowsOrderedByScore() async {
    Database db = await instance.database;
    return await db.query(table, orderBy: '$columnScore DESC');
  }

  // Método para consultar um utilizador pelo nome de utilizador para usar no login
  Future<Map<String, dynamic>?> queryUserByUsername(String username) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> users = await db.query(
      table,
      where: '$columnName = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }
}
