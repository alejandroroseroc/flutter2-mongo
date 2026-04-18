import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AgregarScreen extends StatefulWidget {
  final String pacienteId;

  const AgregarScreen({
    super.key,
    required this.pacienteId,
  });
  @override
  State<AgregarScreen> createState() => _AgregarScreenState();
}

class _AgregarScreenState extends State<AgregarScreen> {
  final _fechaCtrl = TextEditingController();
  final _diagnosticoCtrl = TextEditingController();
  final _medCtrl = TextEditingController();
  final _medicoCtrl = TextEditingController();

  bool _guardando = false;
  String _mensaje = '';

  String? _validar() {
    if (_fechaCtrl.text.trim().isEmpty) return 'Escribe la fecha.';
    if (_diagnosticoCtrl.text.trim().isEmpty) return 'Escribe el diagnóstico.';
    if (_medCtrl.text.trim().isEmpty) return 'Escribe el medicamento.';
    if (_medicoCtrl.text.trim().isEmpty) return 'Escribe el nombre del médico.';

    final regExp = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regExp.hasMatch(_fechaCtrl.text.trim())) {
      return 'La fecha debe tener formato AAAA-MM-DD.';
    }

    return null;
  }

  Future<void> _guardar() async {
    final error = _validar();

    if (error != null) {
      setState(() => _mensaje = error);
      return;
    }

    setState(() {
      _guardando = true;
      _mensaje = '';
    });

    try {
      final exito = await ApiService.agregarConsulta(
        widget.pacienteId,
        {
          'fecha': _fechaCtrl.text.trim(),
          'diagnostico': _diagnosticoCtrl.text.trim(),
          'medicamento': _medCtrl.text.trim(),
          'medico': _medicoCtrl.text.trim(),
        },
      );

      if (!mounted) return;

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consulta guardada correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        setState(() => _mensaje = 'Paciente no encontrado.');
      }
    } catch (e) {
      setState(() {
        _mensaje = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Widget _campo(TextEditingController ctrl, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fechaCtrl.dispose();
    _diagnosticoCtrl.dispose();
    _medCtrl.dispose();
    _medicoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Consulta'),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _campo(_fechaCtrl, 'Fecha', 'AAAA-MM-DD'),
            _campo(_diagnosticoCtrl, 'Diagnóstico', 'Ej: Gripe estacional'),
            _campo(_medCtrl, 'Medicamento', 'Ej: Paracetamol 500mg'),
            _campo(_medicoCtrl, 'Médico', 'Ej: Dr. Pérez'),
            if (_mensaje.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _mensaje,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_guardando ? 'Guardando...' : 'Guardar Consulta'),
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