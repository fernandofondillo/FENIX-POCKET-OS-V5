// lib/views/capsules/capsules_screen.dart
// Catálogo de 7 cápsulas de personalidad V5.
// Integra CapsuleDetector para mostrar la cápsula activa destacada.

import 'package:flutter/material.dart';

import '../../services/capsule_detector.dart';

class CapsulesScreen extends StatefulWidget {
  const CapsulesScreen({Key? key}) : super(key: key);

  @override
  State<CapsulesScreen> createState() => _CapsulesScreenState();
}

class _CapsulesScreenState extends State<CapsulesScreen> {
  String _capsulaActiva = 'general_coordinator';

  final List<Map<String, String>> _capsulas = const [
    {
      'id': 'general_coordinator',
      'nombre': 'Fénix Base',
      'subtitulo': 'Orquestador Soberano Multi-Dominio',
      'version': 'core_v1.zip',
      'descripcion': 'Núcleo de coordinación general. Activo por defecto si no se detecta dominio específico.',
    },
    {
      'id': 'fitness_expert',
      'nombre': 'Biomecánica de Fuerza',
      'subtitulo': 'Prevención de Lesiones & Hipertrofia',
      'version': 'fit_v2.zip',
      'descripcion': 'Cápsula experta en entrenamiento, pesas, cardio y rutinas seguras.',
    },
    {
      'id': 'nutricion_expert',
      'nombre': 'Cetosis Avanzada',
      'subtitulo': 'Rendimiento Celular & Macros',
      'version': 'nutri_v2.zip',
      'descripcion': 'Cápsula experta en dieta, ayuno, proteínas y suplementación.',
    },
    {
      'id': 'zen_mentor',
      'nombre': 'Estoicismo Moderno',
      'subtitulo': 'Meditación & Gestión Emocional',
      'version': 'zen_v1.zip',
      'descripcion': 'Cápsula para ansiedad, estrés, respiración y filosofía estoica.',
    },
    {
      'id': 'biohacking_expert',
      'nombre': 'Biohacking & Longevidad',
      'subtitulo': 'Sueño, Nootrópicos & Circadianos',
      'version': 'bio_v1.zip',
      'descripcion': 'Cápsula de biohacking, dopamina, ritmo circadiano y rendimiento.',
    },
    {
      'id': 'pro_work_assistant',
      'nombre': 'Work Assistant Pro',
      'subtitulo': 'Productividad, Código & Finanzas',
      'version': 'pro_v1.zip',
      'descripcion': 'Cápsula ejecutiva: reuniones, código, Excel, emails, deadlines.',
    },
    {
      'id': 'elderly_care',
      'nombre': 'Elderly Care',
      'subtitulo': 'Cuidado de Mayores & Articulaciones',
      'version': 'elder_v1.zip',
      'descripcion': 'Cápsula para cuidado de abuelos, tensión, memoria y articulaciones.',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Detección inmediata (router pre-procesamiento, NO selector manual)
    final trigger = _triggerTest();
    if (trigger.isNotEmpty) {
      _capsulaActiva = CapsuleDetector.detectar_capsula(trigger);
    }
  }

  String _triggerTest() => ''; // Sin trigger = general_coordinator

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        title: const Text('CÁPSULAS E IDENTIDAD',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF0D0D12),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Color(0xFFD4AF37), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cápsula activa: [NODE: $_capsulaActiva]',
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._capsulas.map((c) => _buildCapsulaCard(c)),
        ],
      ),
    );
  }

  Widget _buildCapsulaCard(Map<String, String> c) {
    final activa = c['id'] == _capsulaActiva;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activa ? const Color(0xFFD4AF37) : Colors.white12,
          width: activa ? 1.5 : 0.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                activa ? Icons.check_circle : Icons.diamond_outlined,
                color: activa ? const Color(0xFFD4AF37) : const Color(0xFF4C8CFA),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  c['nombre']!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: activa ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
              Text(
                c['version']!,
                style: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            c['subtitulo']!,
            style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          Text(
            c['descripcion']!,
            style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_download_outlined, size: 14),
                label: const Text('Montar →', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4C8CFA),
                  side: const BorderSide(color: Color(0xFF4C8CFA)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
              const SizedBox(width: 8),
              if (activa)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFD4AF37)),
                  ),
                  child: const Text('✓ ACTIVA',
                      style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold)),
                )
              else
                ElevatedButton(
                  onPressed: () => setState(() => _capsulaActiva = c['id']!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C8CFA),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('Activar', style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
