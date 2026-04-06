import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'historial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _idController = TextEditingController();
  bool _cargando = false;
  String _error = '';

  Future<void> _buscar() async {
    if (_idController.text.trim().isEmpty) {
      setState(() => _error = 'Por favor escribe un ID de paciente.');
      return;
    }

    setState(() {
      _cargando = true;
      _error = '';
    });

    try {
      final historial = await ApiService.buscarHistorial(
        _idController.text.trim(),
      );

      if (!mounted) return;

      if (historial == null) {
        setState(() => _error = 'Paciente no encontrado. Verifica el ID.');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HistorialScreen(historial: historial),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Clínico'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_hospital, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Buscar Historial de Paciente',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'ID del Paciente',
                hintText: 'Ej: PAC-001',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_search),
              ),
            ),
            const SizedBox(height: 16),
            if (_error.isNotEmpty)
              Text(
                _error,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _cargando ? null : _buscar,
                icon: _cargando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(_cargando ? 'Buscando...' : 'Buscar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}