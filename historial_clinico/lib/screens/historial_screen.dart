import 'package:flutter/material.dart';
import '../models/consulta.dart';
import '../models/historial.dart';
import '../services/api_service.dart';
import 'agregar_screen.dart';

class HistorialScreen extends StatefulWidget {
  final HistorialClinico historial;

  const HistorialScreen({
    super.key,
    required this.historial,
  });

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late HistorialClinico _historialActual;

  final _fechaInicioCtrl = TextEditingController();
  final _fechaFinCtrl = TextEditingController();

  bool _cargando = false;
  String _mensaje = '';

  @override
  void initState() {
    super.initState();
    _historialActual = widget.historial;
  }

  bool _fechaValida(String fecha) {
    return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(fecha);
  }

  Future<void> _recargarHistorial() async {
    setState(() {
      _cargando = true;
      _mensaje = '';
    });

    try {
      final historial = await ApiService.buscarHistorial(
        widget.historial.pacienteId,
      );

      if (!mounted) return;

      if (historial != null) {
        setState(() {
          _historialActual = historial;
        });
      } else {
        setState(() {
          _mensaje = 'Paciente no encontrado.';
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _aplicarFiltro() async {
    final fechaInicio = _fechaInicioCtrl.text.trim();
    final fechaFin = _fechaFinCtrl.text.trim();

    if (fechaInicio.isEmpty || fechaFin.isEmpty) {
      setState(() {
        _mensaje = 'Debes escribir fecha inicio y fecha fin.';
      });
      return;
    }

    if (!_fechaValida(fechaInicio) || !_fechaValida(fechaFin)) {
      setState(() {
        _mensaje = 'Las fechas deben tener formato AAAA-MM-DD.';
      });
      return;
    }

    setState(() {
      _cargando = true;
      _mensaje = '';
    });

    try {
      final historialFiltrado = await ApiService.buscarConFechas(
        widget.historial.pacienteId,
        fechaInicio,
        fechaFin,
      );

      if (!mounted) return;

      if (historialFiltrado != null) {
        setState(() {
          _historialActual = historialFiltrado;
        });
      } else {
        setState(() {
          _mensaje = 'Paciente no encontrado.';
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _limpiarFiltro() async {
    _fechaInicioCtrl.clear();
    _fechaFinCtrl.clear();
    await _recargarHistorial();
  }

  Future<void> _abrirAgregarConsulta() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AgregarScreen(
          pacienteId: widget.historial.pacienteId,
        ),
      ),
    );

    if (resultado == true) {
      await _recargarHistorial();
    }
  }

  Widget _infoCard() {
    return Card(
      margin: const EdgeInsets.all(12),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paciente: ${_historialActual.nombre}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'ID: ${_historialActual.pacienteId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Edad: ${_historialActual.edad} años'),
            Text(
              'Alergias: ${_historialActual.alergias.isEmpty ? "Ninguna conocida" : _historialActual.alergias.join(", ")}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtroCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Filtrar consultas por fecha',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fechaInicioCtrl,
              decoration: const InputDecoration(
                labelText: 'Fecha inicio',
                hintText: 'AAAA-MM-DD',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fechaFinCtrl,
              decoration: const InputDecoration(
                labelText: 'Fecha fin',
                hintText: 'AAAA-MM-DD',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _aplicarFiltro,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                    ),
                    child: const Text('Aplicar filtro'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cargando ? null : _limpiarFiltro,
                    child: const Text('Limpiar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _consultaCard(Consulta consulta, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[800],
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          consulta.diagnostico,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: ${consulta.fecha}'),
            Text('Medicamento: ${consulta.medicamento}'),
            Text('Médico: ${consulta.medico}'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  void dispose() {
    _fechaInicioCtrl.dispose();
    _fechaFinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final consultas = _historialActual.consultas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial del Paciente'),
        backgroundColor: Colors.green[800],
      ),
      body: Column(
        children: [
          _infoCard(),
          _filtroCard(),
          if (_mensaje.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _mensaje,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Consultas médicas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : consultas.isEmpty
                    ? const Center(
                        child: Text('No hay consultas para mostrar'),
                      )
                    : ListView.builder(
                        itemCount: consultas.length,
                        itemBuilder: (context, index) {
                          final consulta =
                              consultas[consultas.length - 1 - index];
                          return _consultaCard(consulta, index);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _cargando ? null : _abrirAgregarConsulta,
        icon: const Icon(Icons.add),
        label: const Text('Nueva consulta'),
        backgroundColor: Colors.green[800],
      ),
    );
  }
}