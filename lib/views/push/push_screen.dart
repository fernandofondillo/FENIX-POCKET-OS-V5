// lib/views/push/push_screen.dart
// Notificaciones Push: configuración de switches (simulado, sin Firebase real).

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PushScreen extends StatefulWidget {
  const PushScreen({Key? key}) : super(key: key);

  @override
  State<PushScreen> createState() => _PushScreenState();
}

class _PushScreenState extends State<PushScreen> {
  final _storage = const FlutterSecureStorage();
  bool _capacitacionDiaria = true;
  bool _alertaMedica = true;
  bool _resumenSemanal = false;
  bool _emergencias = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cap = await _storage.read(key: 'push_capacitacion');
    final med = await _storage.read(key: 'push_medica');
    final sem = await _storage.read(key: 'push_semanal');
    final eme = await _storage.read(key: 'push_emergencias');
    if (mounted) {
      setState(() {
        _capacitacionDiaria = cap != 'false';
        _alertaMedica = med != 'false';
        _resumenSemanal = sem == 'true';
        _emergencias = eme != 'false';
      });
    }
  }

  Future<void> _save(String key, bool value) async {
    await _storage.write(key: 'push_$key', value: value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        title: const Text('NOTIFICACIONES PUSH',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF0D0D12),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFD4AF37), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Fénix puede enviarte notificaciones proactivas. Configura qué tipo de alertas quieres recibir.',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _switchTile('Capacitación Diaria', 'Recordatorios de biomecánica y postura', _capacitacionDiaria, (v) {
            setState(() => _capacitacionDiaria = v);
            _save('capacitacion', v);
          }),
          _switchTile('Alerta Médica', 'Si detecta lesión o dolor en tus mensajes', _alertaMedica, (v) {
            setState(() => _alertaMedica = v);
            _save('medica', v);
          }),
          _switchTile('Resumen Semanal', 'Consolidación de métricas cada domingo', _resumenSemanal, (v) {
            setState(() => _resumenSemanal = v);
            _save('semanal', v);
          }),
          _switchTile('Emergencias', 'Alertas críticas (no silenciables)', _emergencias, (v) {
            setState(() => _emergencias = v);
            _save('emergencias', v);
          }),
        ],
      ),
    );
  }

  Widget _switchTile(String titulo, String subtitulo, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitulo, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF4C8CFA),
      ),
    );
  }
}
