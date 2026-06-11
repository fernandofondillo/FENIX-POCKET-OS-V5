// lib/views/payload/payload_screen.dart
// VPS Payload & Logs: muestra telemetría de instrumentación en tiempo real.
// Integra lectura de estado de Qwen vía header (sin API directa, soberano).

import 'package:flutter/material.dart';

class PayloadScreen extends StatefulWidget {
  const PayloadScreen({Key? key}) : super(key: key);

  @override
  State<PayloadScreen> createState() => _PayloadScreenState();
}

class _PayloadScreenState extends State<PayloadScreen> {
  int _ramUsada = 272;
  late Stream<int> _ramStream;

  @override
  void initState() {
    super.initState();
    // Stream simulado de telemetría (en producción, feed desde el VPS)
    _ramStream = Stream.periodic(const Duration(seconds: 2), (i) {
      return 200 + (i * 37) % 800;
    });
    _ramStream.listen((v) {
      if (mounted) setState(() => _ramUsada = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        title: const Text('VPS PAYLOAD & LOGS',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF0D0D12),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _telemetriaCard(),
            const SizedBox(height: 16),
            _contratoApiCard(),
            const SizedBox(height: 16),
            _ejemploPayloadCard(),
          ],
        ),
      ),
    );
  }

  Widget _telemetriaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TELEMETRÍA DE INSTRUMENTOS',
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          _metricaLine('SMARTPHONE MEMORY', '$_ramUsada/4096 MB'),
          const SizedBox(height: 4),
          _metricaLine('STATELESS VPS', '● ACTIVE', conPunto: true),
          const SizedBox(height: 4),
          _metricaLine('QWEN 7B Q4_K_M', 'llama-server :8090'),
          const SizedBox(height: 4),
          _metricaLine('REDIS ARQ POOL', 'localhost:6379'),
        ],
      ),
    );
  }

  Widget _metricaLine(String label, String valor, {bool conPunto = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11, fontFamily: 'monospace')),
        Text(
          valor,
          style: TextStyle(
            color: conPunto ? const Color(0xFF4CAF50) : const Color(0xFFD4AF37),
            fontSize: 11,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _contratoApiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(8)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CONTRATO API (snake_case estricto)',
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          SizedBox(height: 8),
          Text('POST /api/v1/chat → 202 + task_id\nGET /api/v1/task/{task_id} → 200 + response',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace', height: 1.5)),
        ],
      ),
    );
  }

  Widget _ejemploPayloadCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF0D0D12), borderRadius: BorderRadius.circular(8)),
        child: const SingleChildScrollView(
          child: Text(
            '''{
  "user_id": "uuid-v4-anonimo",
  "mensaje_actual": "...",
  "perfil_identidad": "ID=...\\\\nRol=...\\\\nMeta=...",
  "contexto_rag_hibrido": {
    "historial_usuario": "",
    "conocimiento_experto": ""
  },
  "capsula_activa": {
    "id": "general_coordinator",
    "system_prompt": "...",
    "allowed_skills": ["agenda_crear", ...]
  },
  "active_skills": [],
  "historial_reciente": []
}''',
            style: TextStyle(color: Color(0xFF4C8CFA), fontSize: 11, fontFamily: 'monospace', height: 1.4),
          ),
        ),
      ),
    );
  }
}
