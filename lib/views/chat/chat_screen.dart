// lib/views/chat/chat_screen.dart
// Nexus Console V5: chat con wire-up real al backend A.G.O.S.
// Wire-up: EAV → CapsuleDetector → ApiService (202+polling) → render con badge NODE.

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/app_config.dart';
import '../../models/payload_request.dart';
import '../../services/api_service.dart';
import '../../services/capsule_detector.dart';
import '../../services/perfil_db_service.dart';
import '../../services/skills_service.dart';
import '../../services/emotion_detector.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _storage = const FlutterSecureStorage();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _apiService = ApiService();
  final _perfilDb = PerfilDbService();
  final _skillsService = SkillsService();

  final List<_Mensaje> _mensajes = [];
  String _capsulaActiva = 'general_coordinator';
  String _userId = '';
  bool _isLoading = false;
  int _latenciaMs = 0;
  final _emotionDetector = EmotionDetector();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _userId = (await _storage.read(key: 'user_id')) ?? 'anonimo';
    await _perfilDb.initDb();
    await _emotionDetector.init();
    // Mensaje inicial (punto 24.1.5: sin cápsula = Fénix Base)
    final perfil = await _perfilDb.renderEavComoString();
    final nombre = _extraerEav(perfil, 'nombre_usuario') ?? 'Soberano';
    setState(() {
      _mensajes.add(_Mensaje(
        texto: 'Saludos, $nombre. Soy tu compañero Fénix. He cargado la base cognitiva de tu cápsula activa y decodificado los diarios locales en RAM de forma segura. ¿Qué consulta coordinamos hoy?',
        esUsuario: false,
        emocion: 'neutral',
      ));
    });
  }

  String? _extraerEav(String eav, String clave) {
    for (final linea in eav.split('\n')) {
      if (linea.contains(clave)) {
        return linea.split('=').last.trim();
      }
    }
    return null;
  }

  Future<void> _enviar() async {
    final texto = _inputController.text.trim();
    if (texto.isEmpty || _isLoading) return;

    setState(() {
      _mensajes.add(_Mensaje(texto: texto, esUsuario: true, emocion: 'neutral'));
      _isLoading = true;
      _inputController.clear();
    });
    _scrollToBottom();

    final t0 = DateTime.now();
    try {
      // 1. Detectar cápsula activa (router pre-procesamiento, NO selector)
      final capsulaId = CapsuleDetector.detectar_capsula(texto);
      _capsulaActiva = capsulaId;

      // 2. Renderizar EAV como STRING (lo que Pydantic espera)
      final perfilString = await _perfilDb.renderEavComoString();

      // 3. Construir payload snake_case
      final systemPrompt = _obtenerSystemPrompt(capsulaId);
      final payload = PayloadRequest(
        userId: _userId,
        mensajeActual: texto,
        perfilIdentidad: perfilString,
        contextoRagHibrido: const {'historial_usuario': '', 'conocimiento_experto': ''},
        capsulaActiva: {
          'id': capsulaId,
          'system_prompt': systemPrompt,
          'allowed_skills': _skillsService.listar_habilidades_permitidas(SkillsService.built_in),
        },
        activeSkills: const [],
        historialReciente: _mensajes
            .where((m) => m.texto.isNotEmpty)
            .take(8)
            .map((m) => {'role': m.esUsuario ? 'user' : 'assistant', 'content': m.texto})
            .toList(),
      );

      // 4. POST + polling
      final response = await _apiService.enviarMensajeConPolling(payload);
      _latenciaMs = DateTime.now().difference(t0).inMilliseconds;

      // 5. Renderizar response
      final assistantText = response['assistant_response'] ?? '';
      // 6. Detectar emoción (async, devuelve Map con 'label')
      String emocion = 'neutral';
      try {
        final emocionMap = await _emotionDetector.detectar_emocion(assistantText);
        emocion = emocionMap['label']?.toString() ?? 'neutral';
      } catch (_) {}
      setState(() {
        _mensajes.add(_Mensaje(texto: assistantText, esUsuario: false, emocion: emocion));
      });

      // 6. Mostrar burbuja analítica de skills (punto 24.1.2)
      final executedSkills = response['executed_skills'] as List? ?? [];
      for (final skill in executedSkills) {
        if (skill is Map) {
          setState(() {
            _mensajes.add(_Mensaje(
              texto: '⚙️ EXECUTED: ${skill['name'] ?? 'unknown'} → ${skill['result'] ?? 'OK'}',
              esUsuario: false,
              emocion: 'skill',
            ));
          });
        }
      }
    } catch (e) {
      setState(() {
        _mensajes.add(_Mensaje(
          texto: '⚠️ Error de transmisión: $e',
          esUsuario: false,
          emocion: 'error',
        ));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  String _obtenerSystemPrompt(String capsulaId) {
    const prompts = {
      'general_coordinator': 'Eres Fénix, asistente personal soberano y orquestador base. Responde de manera concisa, técnica y sobria. Sin emojis afectivos. Tono: soberano a soberano.',
      'fitness_expert': 'Eres un experto en biomecánica, fuerza y prevención de lesiones. Tono técnico, citas métricas concretas. Sin emojis afectivos.',
      'nutricion_expert': 'Eres un experto en nutrición, cetosis, ayuno y rendimiento celular. Tono técnico, basado en evidencia. Sin emojis afectivos.',
      'zen_mentor': 'Eres un mentor de meditación y estoicismo. Tono calmado, reflexivo, técnico. Sin emojis afectivos.',
      'biohacking_expert': 'Eres un experto en biohacking, longevidad, sueño, nootrópicos. Tono técnico, basado en evidencia. Sin emojis afectivos.',
      'pro_work_assistant': 'Eres un asistente de productividad, código, finanzas y proyectos. Tono ejecutivo, directo. Sin emojis afectivos.',
      'elderly_care': 'Eres un asistente de cuidado de mayores. Tono cálido pero técnico, respetuoso. Sin emojis afectivos.',
    };
    return prompts[capsulaId] ?? prompts['general_coordinator']!;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D12),
        elevation: 0,
        title: Column(
          children: [
            const Text('NEXUS CONSOLE',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 2),
            Text('[NODE: $_capsulaActiva] • ${_latenciaMs}ms',
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10, letterSpacing: 1)),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length + (_isLoading ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == _mensajes.length) return _buildLoadingBubble();
                return _buildBurbuja(_mensajes[i]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            color: const Color(0xFF0D0D12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A24),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _inputController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Integrar comando léxico...',
                        hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (_) => _enviar(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(color: Color(0xFF4C8CFA), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                    onPressed: _isLoading ? null : _enviar,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBurbuja(_Mensaje m) {
    Color bgColor;
    Color textColor = Colors.white;
    if (m.emocion == 'skill') {
      bgColor = const Color(0xFF0D0D12);
      textColor = const Color(0xFFD4AF37);
    } else if (m.emocion == 'error') {
      bgColor = const Color(0xFF3A1A1A);
    } else {
      bgColor = m.esUsuario ? const Color(0xFF1A1A24) : const Color(0xFF1A2A3A);
    }
    return Align(
      alignment: m.esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16).copyWith(
            topLeft: m.esUsuario ? const Radius.circular(16) : const Radius.circular(4),
            topRight: m.esUsuario ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: m.emocion == 'skill' ? Border.all(color: const Color(0xFFD4AF37), width: 0.5) : null,
        ),
        child: Text(m.texto, style: TextStyle(color: textColor, height: 1.4, fontSize: 14)),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF1A1A24), borderRadius: BorderRadius.circular(16)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4C8CFA))),
            SizedBox(width: 12),
            Text('⏳ Infiriendo en VPS...', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _Mensaje {
  final String texto;
  final bool esUsuario;
  final String emocion;
  _Mensaje({required this.texto, required this.esUsuario, required this.emocion});
}
