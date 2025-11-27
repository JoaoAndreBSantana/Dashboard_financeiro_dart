import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Classe que gerencia a conexão e criação do banco de dados SQFlite.
class DatabaseHelper {
 
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Armazena a instância do banco de dados para não reabrir a cada chamada.
  static Database? _database;

  /// Getter para o banco 
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// inicializacao
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finance.db');//nome do banco de dados
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  
  Future<void> _createDB(Database db, int version) async {
    // Cria a tabela de categorias.
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        color TEXT NOT NULL
      )
    ''');

    // Cria a tabela de transações.
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
  }
}