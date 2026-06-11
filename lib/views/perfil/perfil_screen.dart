// lib/views/perfil/perfil_screen.dart
// Lee TODOS los EAV del PerfilDbService y los muestra en lista.

import 'package:flutter/material.dart';
import '../../services/perfil_db_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _db = PerfilDbService();
  List<Map<String, dynamic>> _eavs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEavs();
  }

  Future<void> _loadEavs() async {
    await _db.initDb();
    final rows = await _db.obtenerTodosEavs();
    setState(() {
      _eavs = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        title: const Text('PERFIL EAV',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF0D0D12),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4C8CFA)))
          : _eavs.isEmpty
              ? const Center(child: Text('Sin datos EAV. Completa el onboarding.', style: TextStyle(color: Colors.white54)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _eavs.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (ctx, i) {
                    final e = _eavs[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${e['categoria']}.${e['clave']}',
                        style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontFamily: 'monospace'),
                      ),
                      subtitle: Text(
                        e['valor']?.toString() ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    );
                  },
                ),
    );
  }
}
