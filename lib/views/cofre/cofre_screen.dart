// lib/views/cofre/cofre_screen.dart
// Cofre de Código Fénix: editor de texto donde el usuario mete su propio código.
// Se guarda en SecureStorage cifrado AES-256.

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CofreScreen extends StatefulWidget {
  const CofreScreen({Key? key}) : super(key: key);

  @override
  State<CofreScreen> createState() => _CofreScreenState();
}

class _CofreScreenState extends State<CofreScreen> {
  final _controller = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _guardado = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final codigo = await _storage.read(key: 'cofre_codigo');
    if (codigo != null) _controller.text = codigo;
  }

  Future<void> _guardar() async {
    await _storage.write(key: 'cofre_codigo', value: _controller.text);
    setState(() => _guardado = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _guardado = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        title: const Text('COFRE DE CÓDIGO FÉNIX',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF0D0D12),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
              ),
              child: const Text(
                'Bóveda cifrada AES-256 con tu master_key. Fénix NO ejecuta código, solo lo lee como contexto.',
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, height: 1.4),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                style: const TextStyle(color: Color(0xFF4C8CFA), fontSize: 13, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0D0D12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  hintText: '// Pega aquí tu código (Python, JS, TS, Dart, SQL...)\n// Fénix lo almacenará cifrado en tu bóveda local.',
                  hintStyle: const TextStyle(color: Colors.white24, fontFamily: 'monospace', fontSize: 12),
                ),
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _guardar,
                    icon: Icon(_guardado ? Icons.check : Icons.lock_outline, color: Colors.white, size: 16),
                    label: Text(_guardado ? 'GUARDADO' : 'GUARDAR EN BÓVEDA',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _guardado ? const Color(0xFF4CAF50) : const Color(0xFF4C8CFA),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
