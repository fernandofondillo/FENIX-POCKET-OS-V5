// lib/services/perfil_db_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PerfilDbService {
  Database? _db;

  Future<void> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fenix_perfil.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE eav_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            categoria TEXT NOT NULL,
            clave TEXT UNIQUE NOT NULL,
            valor TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> upsertEav(String categoria, String clave, String valor) async {
    if (_db == null) await initDb();
    await _db!.insert(
      'eav_data',
      {'categoria': categoria, 'clave': clave, 'valor': valor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Lee TODOS los EAV y los renderiza como string "categoria.clave=valor" multilínea.
  /// Coincide con `perfil_identidad: str` en el contrato Pydantic backend.
  /// Usado por ChatScreen antes de enviar el payload.
  Future<String> renderEavComoString() async {
    if (_db == null) await initDb();
    final List<Map<String, dynamic>> rows = await _db!.query('eav_data');
    if (rows.isEmpty) return 'ID=Anónimo\nRol=Sin definir\nMeta=Sin definir';
    final lines = rows.map((r) => '${r['categoria']}.${r['clave']}=${r['valor']}').toList();
    return lines.join('\n');
  }

  /// Devuelve todos los EAV como lista de mapas (categoria, clave, valor).
  /// Usado por PerfilScreen para mostrar la tabla EAV completa.
  Future<List<Map<String, dynamic>>> obtenerTodosEavs() async {
    if (_db == null) await initDb();
    return await _db!.query('eav_data');
  }
}
