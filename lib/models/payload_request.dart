// lib/models/payload_request.dart
// Contrato de datos V5 hacia el backend A.G.O.S. (FastAPI/Pydantic).
// Coincide snake_case estricto con ChatRequest en app/schemas/chat_schema.py.

class PayloadRequest {
  /// ID anónimo del usuario (UUID v4 generado en onboarding).
  final String userId;

  /// El prompt terminal a inferir.
  final String mensajeActual;

  /// String ultradenso del EAV SQLite renderizado por PerfilDbService.
  /// Coincide con `perfil_identidad: str` en Pydantic.
  final String perfilIdentidad;

  /// RAG híbrido local: historial de usuario + conocimiento experto.
  /// Coincide con `contexto_rag_hibrido: RagContext` en Pydantic.
  final Map<String, String> contextoRagHibrido;

  /// Detalles de la cápsula de personalidad activa.
  /// Coincide con `capsula_activa: CapsulaActiva` en Pydantic.
  final Map<String, dynamic> capsulaActiva;

  /// Skills globales actualmente conectadas al UI dinámico.
  /// Coincide con `active_skills: List[str]` en Pydantic.
  final List<String> activeSkills;

  /// Cola FIFO de historial reciente (últimos 8 mensajes).
  /// Coincide con `historial_reciente: List[Message]` en Pydantic.
  final List<Map<String, String>> historialReciente;

  PayloadRequest({
    required this.userId,
    required this.mensajeActual,
    required this.perfilIdentidad,
    required this.contextoRagHibrido,
    required this.capsulaActiva,
    required this.activeSkills,
    required this.historialReciente,
  });

  /// Serializa el objeto a Map snake_case estricto, válido para FastAPI/Pydantic.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'mensaje_actual': mensajeActual,
      'perfil_identidad': perfilIdentidad,
      'contexto_rag_hibrido': contextoRagHibrido,
      'capsula_activa': capsulaActiva,
      'active_skills': activeSkills,
      'historial_reciente': historialReciente,
    };
  }
}
