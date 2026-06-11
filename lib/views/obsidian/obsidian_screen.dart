// lib/views/obsidian/obsidian_screen.dart
// Nano-Obsidian Vault: muestra el historial de mensajes de la sesión actual.
// Integra MemoryService (FIFO 8 mensajes) y LocalEmbeddingService (RAG local).

import 'package:flutter/material.dart';
import '../../services/memory_service.dart';

class ObsidianScreen extends StatefulWidget {
  const ObsidianScreen({Key? key}) : super(key: key);

  @override
  State<ObsidianScreen> createState() => _ObsidianScreenState();
}

class _ObsidianScreenState extends State<ObsidianScreen> {
  final _memoria = MemoryService();
  List<String> _historial = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistorial();
  }

  Future<void> _loadHistorial() async {
    await _memoria.init_memory();
    final ultimos = _memoria.obtener_memoria_inmediata();
    setState(() {
      _historial = ultimos.map((m) => '[${m['rol']}] ${m['contenido']}').toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        title: const Text('NANO-OBSIDIAN VAULT',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF0D0D12),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF0D0D12),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: Color(0xFFD4AF37), size: 14),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Diario cifrado AES-256 • FIFO 8 mensajes • RAG local TFLite',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4C8CFA)))
                : _historial.isEmpty
                    ? const Center(
                        child: Text('El diario está vacío.\nInicia una conversación en Nexus Console.',
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, height: 1.5)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _historial.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) => Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A24),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(_historial[i], style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
