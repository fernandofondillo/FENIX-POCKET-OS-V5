// lib/services/api_service.dart
// Servicio HTTP hacia el backend A.G.O.S. (V5).
// Implementa el flujo event-driven: POST /chat (HTTP 202 + task_id) → polling.

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import '../models/payload_request.dart';

class ApiService {
  final String _baseUrl;

  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  /// Despacha el payload denso al endpoint ingestor (HTTP 202 + task_id)
  /// y delega la responsabilidad a un ciclo de long-polling cada 800ms.
  Future<Map<String, dynamic>> enviarMensajeConPolling(PayloadRequest payload) async {
    final String urlIngesta = '$_baseUrl/api/v1/chat';

    print('[API_SERVICE] Despachando ráfaga → $urlIngesta');

    try {
      final respIngesta = await http.post(
        Uri.parse(urlIngesta),
        headers: AppConfig.ngrokHeaders,
        body: jsonEncode(payload.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (respIngesta.statusCode == 202) {
        final Map<String, dynamic> datosIngesta = jsonDecode(respIngesta.body);
        if (datosIngesta['status'] == 'queued' && datosIngesta.containsKey('task_id')) {
          final String taskId = datosIngesta['task_id'];
          print('[API_SERVICE] Tarea encolada. Task ID: $taskId');
          return await _buclePolling(taskId);
        }
        throw Exception('Respuesta anómala del ingestor 202: ${respIngesta.body}');
      } else {
        throw Exception('Fallo HTTP ${respIngesta.statusCode} en POST /chat: ${respIngesta.body}');
      }
    } catch (e) {
      print('[API_SERVICE_ERROR] $e');
      rethrow;
    }
  }

  /// Long-polling cada 800ms, timeout 90s (Qwen 7B CPU puede tardar 30-60s).
  Future<Map<String, dynamic>> _buclePolling(String taskId) async {
    final String urlPolling = '$_baseUrl/api/v1/task/$taskId';
    final int intervaloMs = 800;
    final int timeoutSeg = 90;

    final DateTime t0 = DateTime.now();
    int intento = 0;

    while (true) {
      if (DateTime.now().difference(t0).inSeconds > timeoutSeg) {
        throw Exception('Timeout ${timeoutSeg}s esperando tarea $taskId. VPS saturado o Qwen fuera de línea.');
      }

      try {
        final resp = await http.get(Uri.parse(urlPolling), headers: AppConfig.ngrokHeaders)
            .timeout(const Duration(seconds: 10));

        if (resp.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(resp.body);
          final String estado = data['status'];

          if (estado == 'completed' && data.containsKey('result')) {
            print('[API_SERVICE] ✅ Tarea $taskId completada (intento $intento)');
            return data['result'] as Map<String, dynamic>;
          } else if (estado == 'processing' || estado == 'queued') {
            if (intento % 5 == 0) {
              print('[API_SERVICE] [$intento] $estado...');
            }
          } else if (estado == 'error') {
            throw Exception('Error en worker Arq para $taskId');
          }
        } else {
          throw Exception('HTTP ${resp.statusCode} en GET /task/$taskId');
        }
      } catch (e) {
        print('[API_SERVICE_REINTENTO] $e');
      }

      intento++;
      await Future.delayed(Duration(milliseconds: intervaloMs));
    }
  }
}
