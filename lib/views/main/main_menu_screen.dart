// lib/views/main/main_menu_screen.dart
// Hub central de Fénix V5 con 6 secciones del menú (Drawer lateral con swipe + hamburguesa).
// Diseño coherente con README V2 + punto 24 del CTO.

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth/welcome_screen.dart';
import '../chat/chat_screen.dart';
import '../perfil/perfil_screen.dart';
import '../capsules/capsules_screen.dart';
import '../obsidian/obsidian_screen.dart';
import '../payload/payload_screen.dart';
import '../cofre/cofre_screen.dart';
import '../push/push_screen.dart';
import '../skills/skills_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final _storage = const FlutterSecureStorage();
  String _userIdShort = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final id = await _storage.read(key: 'user_id');
    if (mounted) setState(() => _userIdShort = (id ?? '').substring(0, 8));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A),
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text(
          'ARQUITECTURA SOBERANA',
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        backgroundColor: const Color(0xFF0D0D12),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header técnico multi-capa (punto 24.2.3)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: const Color(0xFF0D0D12),
            child: Column(
              children: [
                Text('FÉNIX PERSONAL ASSISTANT • v5.0-Prod',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10, letterSpacing: 2)),
                const SizedBox(height: 4),
                Text('USER: $_userIdShort',
                    style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _menuCard(context, '01', 'Cápsulas e Identidad', Icons.diamond_outlined, const CapsulesScreen()),
                  _menuCard(context, '02', 'Nano-Obsidian Vault', Icons.folder_outlined, const ObsidianScreen()),
                  _menuCard(context, '03', 'VPS Payload & Logs', Icons.terminal_outlined, const PayloadScreen()),
                  _menuCard(context, '04', 'Cofre de Código Fénix', Icons.code_outlined, const CofreScreen()),
                  _menuCard(context, '05', 'Notificaciones Push', Icons.notifications_outlined, const PushScreen()),
                  _menuCard(context, '06', 'Skills Nativas', Icons.layers_outlined, const SkillsScreen()),
                ],
              ),
            ),
          ),
          // Botón principal: ABRIR CHAT (Nexus Console)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                label: const Text('ABRIR NEXUS CONSOLE',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C8CFA),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(BuildContext context, String num, String label, IconData icon, Widget destino) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destino)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4C8CFA).withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(num, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, letterSpacing: 2)),
            const SizedBox(height: 6),
            Icon(icon, color: const Color(0xFF4C8CFA), size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0D0D12),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1A1A24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_moon_outlined, color: Color(0xFF4C8CFA), size: 40),
                const SizedBox(height: 8),
                const Text('FÉNIX OS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('UUID: $_userIdShort', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11)),
              ],
            ),
          ),
          _drawerItem('01', 'Cápsulas e Identidad', Icons.diamond_outlined, () => _nav(const CapsulesScreen())),
          _drawerItem('02', 'Nano-Obsidian Vault', Icons.folder_outlined, () => _nav(const ObsidianScreen())),
          _drawerItem('03', 'VPS Payload & Logs', Icons.terminal_outlined, () => _nav(const PayloadScreen())),
          _drawerItem('04', 'Cofre de Código Fénix', Icons.code_outlined, () => _nav(const CofreScreen())),
          _drawerItem('05', 'Notificaciones Push', Icons.notifications_outlined, () => _nav(const PushScreen())),
          _drawerItem('06', 'Skills Nativas', Icons.layers_outlined, () => _nav(const SkillsScreen())),
          const Divider(color: Colors.white12, height: 32),
          _drawerItem('CHAT', 'Nexus Console', Icons.chat_bubble_outline, () => _nav(const ChatScreen())),
          _drawerItem('CFG', 'Mi Perfil EAV', Icons.person_outline, () => _nav(const PerfilScreen())),
        ],
      ),
    );
  }

  Widget _drawerItem(String num, String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Text(num, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold)),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      trailing: Icon(icon, color: const Color(0xFF4C8CFA), size: 18),
      onTap: () { Navigator.pop(context); onTap(); },
    );
  }

  void _nav(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
