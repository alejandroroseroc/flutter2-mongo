import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/historial.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';


  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  static String _extraerMensaje(String body, {String porDefecto = 'Ocurrió un error'}) {
    try {
      final data = jsonDecode(body);
      return data['mensaje'] ?? porDefecto;
    } catch (_) {
      return porDefecto;
    }
  }

  static Future<HistorialClinico?> buscarHistorial(String pacienteId) async {
    final uri = Uri.parse('$_baseUrl/historiales/$pacienteId');

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return HistorialClinico.fromJson(data['data']);
      }

      if (response.statusCode == 404) {
        return null;
      }

      throw Exception(
        _extraerMensaje(
          response.body,
          porDefecto: 'Error al buscar historial',
        ),
      );
    } catch (e) {
      throw Exception('No se pudo conectar con el backend');
    }
  }

  static Future<bool> agregarConsulta(
    String pacienteId,
    Map<String, dynamic> consulta,
  ) async {
    final uri = Uri.parse('$_baseUrl/historiales/$pacienteId/consultas');

    try {
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(consulta),
      );

      if (response.statusCode == 201) {
        return true;
      }

      if (response.statusCode == 404) {
        return false;
      }

      throw Exception(
        _extraerMensaje(
          response.body,
          porDefecto: 'Error al guardar la consulta',
        ),
      );
    } catch (e) {
      throw Exception('No se pudo conectar con el backend');
    }
  }

  static Future<HistorialClinico?> buscarConFechas(
    String pacienteId,
    String fechaInicio,
    String fechaFin,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl/historiales/$pacienteId?fechaInicio=$fechaInicio&fechaFin=$fechaFin',
    );

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return HistorialClinico.fromJson(data['data']);
      }

      if (response.statusCode == 404) {
        return null;
      }

      throw Exception(
        _extraerMensaje(
          response.body,
          porDefecto: 'Error al filtrar historial',
        ),
      );
    } catch (e) {
      throw Exception('No se pudo conectar con el backend');
    }
  }
}