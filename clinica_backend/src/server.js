const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { MongoClient } = require('mongodb');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const uri = process.env.MONGODB_URI;
const dbName = process.env.DB_NAME || 'clinica_db';
const collectionName = process.env.COLLECTION_NAME || 'historiales';

if (!uri) {
    console.error('Falta MONGODB_URI en el archivo .env');
    process.exit(1);
}

const client = new MongoClient(uri);

let historialesCollection;

// Validador simple de fecha AAAA-MM-DD
function esFechaValida(fecha) {
    return /^\d{4}-\d{2}-\d{2}$/.test(fecha);
}

// Ruta de prueba
app.get('/api/health', (req, res) => {
    res.json({
        ok: true,
        mensaje: 'Backend funcionando correctamente'
    });
});

// 1) Buscar historial por ID de paciente
// GET /api/historiales/PAC-001
// Bonus: también acepta ?fechaInicio=2024-01-01&fechaFin=2024-12-31
app.get('/api/historiales/:pacienteId', async (req, res) => {
    const pacienteId = req.params.pacienteId?.trim();
    const { fechaInicio, fechaFin } = req.query;

    if (!pacienteId) {
        return res.status(400).json({
            ok: false,
            mensaje: 'El pacienteId es obligatorio'
        });
    }

    try {
        // BONUS: filtrar consultas por rango de fechas
        if (fechaInicio || fechaFin) {
            if (!fechaInicio || !fechaFin) {
                return res.status(400).json({
                    ok: false,
                    mensaje: 'Debes enviar fechaInicio y fechaFin'
                });
            }

            if (!esFechaValida(fechaInicio) || !esFechaValida(fechaFin)) {
                return res.status(400).json({
                    ok: false,
                    mensaje: 'Las fechas deben tener formato AAAA-MM-DD'
                });
            }

            const resultado = await historialesCollection.aggregate([
                {
                    $match: { pacienteId }
                },
                {
                    $project: {
                        _id: 0,
                        pacienteId: 1,
                        nombre: 1,
                        edad: 1,
                        alergias: 1,
                        consultas: {
                            $filter: {
                                input: '$consultas',
                                as: 'consulta',
                                cond: {
                                    $and: [
                                        { $gte: ['$$consulta.fecha', fechaInicio] },
                                        { $lte: ['$$consulta.fecha', fechaFin] }
                                    ]
                                }
                            }
                        }
                    }
                }
            ]).toArray();

            if (resultado.length === 0) {
                return res.status(404).json({
                    ok: false,
                    mensaje: 'Paciente no encontrado'
                });
            }

            return res.json({
                ok: true,
                data: resultado[0]
            });
        }

        const historial = await historialesCollection.findOne(
            { pacienteId },
            { projection: { _id: 0 } }
        );

        if (!historial) {
            return res.status(404).json({
                ok: false,
                mensaje: 'Paciente no encontrado'
            });
        }

        return res.json({
            ok: true,
            data: historial
        });
    } catch (error) {
        console.error('Error al buscar historial:', error);
        return res.status(500).json({
            ok: false,
            mensaje: 'Error interno del servidor'
        });
    }
});

// 2) Agregar nueva consulta al arreglo "consultas" con $push
// POST /api/historiales/PAC-001/consultas
app.post('/api/historiales/:pacienteId/consultas', async (req, res) => {
    const pacienteId = req.params.pacienteId?.trim();
    const { fecha, diagnostico, medicamento, medico } = req.body;

    if (!pacienteId) {
        return res.status(400).json({
            ok: false,
            mensaje: 'El pacienteId es obligatorio'
        });
    }

    if (!fecha || !diagnostico || !medicamento || !medico) {
        return res.status(400).json({
            ok: false,
            mensaje: 'Todos los campos son obligatorios'
        });
    }

    if (!esFechaValida(fecha)) {
        return res.status(400).json({
            ok: false,
            mensaje: 'La fecha debe tener formato AAAA-MM-DD'
        });
    }

    try {
        const nuevaConsulta = {
            fecha: fecha.trim(),
            diagnostico: diagnostico.trim(),
            medicamento: medicamento.trim(),
            medico: medico.trim()
        };

        const resultado = await historialesCollection.updateOne(
            { pacienteId },
            { $push: { consultas: nuevaConsulta } }
        );

        if (resultado.matchedCount === 0) {
            return res.status(404).json({
                ok: false,
                mensaje: 'Paciente no encontrado'
            });
        }

        return res.status(201).json({
            ok: true,
            mensaje: 'Consulta agregada correctamente'
        });
    } catch (error) {
        console.error('Error al agregar consulta:', error);
        return res.status(500).json({
            ok: false,
            mensaje: 'Error interno del servidor'
        });
    }
});

async function iniciarServidor() {
    try {
        await client.connect();
        console.log('✅ Conectado a MongoDB Atlas');

        const db = client.db(dbName);
        historialesCollection = db.collection(collectionName);

        app.listen(PORT, () => {
            console.log(`🚀 Backend escuchando en http://localhost:${PORT}`);
        });
    } catch (error) {
        console.error('❌ Error al conectar con MongoDB Atlas:', error);
        process.exit(1);
    }
}

iniciarServidor();