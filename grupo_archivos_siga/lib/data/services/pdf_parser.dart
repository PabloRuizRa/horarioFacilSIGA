import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/asignatura.dart';
import '../models/bloque.dart';
import '../models/horario.dart';

class PdfParser {
  static const String apiUrl = 'http://127.0.0.1:8000/extract-text';

  Future<Horario> parseHorarioFromPDF(File pdfFile, String periodo) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', pdfFile.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (jsonResponse['status'] == 'error') {
        throw Exception('API Error: ${jsonResponse['message']}');
      }

      final textoCompleto = jsonResponse['text'] ?? '';
      print('Texto extraído: ${textoCompleto.substring(0, textoCompleto.length > 200 ? 200 : textoCompleto.length)}...');

      // Crear asignaturas de ejemplo (por ahora)
      final asignaturas = <Asignatura>[
        Asignatura(
          id: 'MAT023',
          nombre: 'Matemáticas III',
          codigo: 'MAT023',
          profesor: 'Dr. Juan Pérez',
          seccion: '001',
          tipo: 'Inscrita',
        ),
        Asignatura(
          id: 'EIN092B',
          nombre: 'Programación Apps Móviles',
          codigo: 'EIN092B',
          profesor: 'David Larrondo',
          seccion: '001',
          tipo: 'Inscrita',
        ),
      ];

      final bloques = <Bloque>[
        Bloque(
          id: 'b1',
          asignaturaId: 'MAT023',
          dia: 'Lunes',
          horaInicio: '08:00',
          horaFin: '10:00',
          sala: 'B-102',
          bloqueNumero: 1,
        ),
        Bloque(
          id: 'b2',
          asignaturaId: 'EIN092B',
          dia: 'Miércoles',
          horaInicio: '14:00',
          horaFin: '17:00',
          sala: 'Lab Móviles',
          bloqueNumero: 7,
        ),
      ];

      return Horario(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: 'Horario $periodo',
        estudiante: 'Estudiante UTFSM',
        periodo: periodo,
        asignaturas: asignaturas,
        bloques: bloques,
      );
    } catch (e) {
      throw Exception('Error al procesar PDF: $e');
    }
  }
}
