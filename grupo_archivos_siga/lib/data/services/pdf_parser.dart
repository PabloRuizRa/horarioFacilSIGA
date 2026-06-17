// ignore_for_file: avoid_print, unused_local_variable
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/asignatura.dart';
import '../models/bloque.dart';
import '../models/horario.dart';

class PdfParser {
  static const String apiUrl = 'http://127.0.0.1:8000/extract-text';

  static const List<String> _rangos = [
    "8:15-8:50", "8:50-9:25", "9:40-10:15", "10:15-10:50",
    "11:05-11:40", "11:40-12:15", "12:30-13:05", "13:05-13:40",
    "14:40-15:15", "15:15-15:50", "16:05-16:40", "16:40-17:15",
    "17:30-18:05", "18:05-18:40", "18:55-19:30", "19:30-20:05",
    "20:20-20:55", "20:55-21:30", "21:45-22:20", "22:20-22:55"
  ];

  Future<Horario> parseHorarioFromBytes(Uint8List pdfBytes, String fileName, String periodo) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(http.MultipartFile.fromBytes('file', pdfBytes, filename: fileName));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (jsonResponse['status'] == 'error') {
        throw Exception('API Error: ${jsonResponse['message']}');
      }

      final String texto = jsonResponse['text'] ?? '';

      // Extraer estudiante
      String estudiante = 'Estudiante UTFSM';
      final estudianteRegex = RegExp(r'Alumno\s*:\s*([^\n]+)');
      final estudianteMatch = estudianteRegex.firstMatch(texto);
      if (estudianteMatch != null) {
        estudiante = estudianteMatch.group(1)!.trim();
      }

      final Map<String, Asignatura> asignaturasMap = {};
      final Map<String, String> salasMap = {};
      final List<Bloque> bloques = [];

      // Extraer asignaturas únicas y salas
      final asignaturaRegex = RegExp(r'([A-Z]{3}\d{3}[A-Z-]*?)\s*-\s*([A-ZÁÉÍÓÚÑa-záéíóúñ0-9\s]+?)\s*\((Inscrita|Preinscrita)\)(?:\s*sala\s+([A-Z0-9]+))?');
      for (var match in asignaturaRegex.allMatches(texto)) {
        final codigo = match.group(1)!.trim();
        final nombre = match.group(2)!.replaceAll(RegExp(r'\s+'), ' ').trim(); 
        final tipo = match.group(3)!.trim();
        final salaExtraida = match.group(4);

        if (salaExtraida != null) salasMap[codigo] = salaExtraida;

        if (!asignaturasMap.containsKey(codigo)) {
          asignaturasMap[codigo] = Asignatura(
            id: codigo, nombre: nombre, codigo: codigo, profesor: 'Por definir', seccion: '1', tipo: tipo,
          );
        }
      }

      final tablaRegex = RegExp(r'([A-Z]{3}\d{3}[A-Z]*)(-[A-Z])?-(\d{3})\s*\((Ins|Pre)\)');
      for (var match in tablaRegex.allMatches(texto)) {
        final codigoBase = match.group(1)!;
        final variante = match.group(2) ?? '';
        final codigoCompleto = '$codigoBase$variante';
        final tipo = match.group(4) == 'Ins' ? 'Inscrita' : 'Preinscrita';

        if (!asignaturasMap.containsKey(codigoCompleto)) {
          asignaturasMap[codigoCompleto] = Asignatura(
            id: codigoCompleto, nombre: 'Asignatura $codigoCompleto', codigo: codigoCompleto, profesor: 'Por definir', seccion: '1', tipo: tipo,
          );
        }
      }

      if (asignaturasMap.isEmpty) {
        throw Exception('No se encontraron asignaturas. Verifica el formato del PDF.');
      }

      // ===================================================================
      // 3. MAPEO DINÁMICO DE BLOQUES
      // ===================================================================
      final dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
      
      int indexDetalle = texto.indexOf('Detalle de horario');
      String detailText = indexDetalle != -1 ? texto.substring(indexDetalle) : texto;

      // Encontrar en qué índice del texto empieza cada día
      List<Map<String, dynamic>> dayChunks = [];
      for (String dia in dias) {
        int idx = detailText.indexOf('"$dia\\n"');
        if (idx == -1) idx = detailText.indexOf('"$dia"');
        if (idx == -1) idx = detailText.indexOf(dia);
        
        if (idx != -1) {
          dayChunks.add({'dia': dia, 'index': idx});
        }
      }
      dayChunks.sort((a, b) => a['index'].compareTo(b['index']));

      // Generar un regex dinámico
      List<String> knownCodes = asignaturasMap.keys.toList();
      String codesPattern = knownCodes.map((c) => RegExp.escape(c)).join('|');
      final codeRegex = RegExp('($codesPattern)');

      // Regex para encontrar los horarios
      final blockRegex = RegExp(r'\b(\d+(?:-\d+)*)\b\s*\(\d{2}:\d{2}[-–]\d{2}:\d{2}\)');

      // Procesar bloque de texto día por día
      for (int i = 0; i < dayChunks.length; i++) {
        String dia = dayChunks[i]['dia'];
        int start = dayChunks[i]['index'];
        int end = (i + 1 < dayChunks.length) ? dayChunks[i + 1]['index'] : detailText.length;
        
        String chunkText = detailText.substring(start, end);

        // Extraer todos los números de bloque que encuentre en ese día
        List<String> blockGroups = [];
        for (var match in blockRegex.allMatches(chunkText)) {
          blockGroups.add(match.group(1)!);
        }

        // Extraer todos los códigos de asignaturas en ese día
        List<String> subjectCodes = [];
        for (var match in codeRegex.allMatches(chunkText)) {
          subjectCodes.add(match.group(1)!);
        }

        // Emparejar 1 a 1 (Zipping)
        int limit = blockGroups.length < subjectCodes.length ? blockGroups.length : subjectCodes.length;
        for (int j = 0; j < limit; j++) {
          String bGroup = blockGroups[j];
          String sCode = subjectCodes[j];

          // Si el bloque es agrupado lo separamos para llenar cada celda
          List<String> parts = bGroup.split('-');
          for (String p in parts) {
            int n = int.parse(p);
            
            // Evitar duplicados si PyPDF leyó la misma celda dos veces
            if (!bloques.any((b) => b.dia == dia && b.numeroBloque == n && b.asignaturaId == sCode)) {
              bloques.add(Bloque(
                id: '${sCode}_${dia}_$n',
                asignaturaId: sCode,
                dia: dia,
                numeroBloque: n,
                horaInicio: _rangos[n - 1].split('-')[0].trim(),
                horaFin: _rangos[n - 1].split('-')[1].trim(),
                sala: salasMap[sCode] ?? 'Por definir',
              ));
            }
          }
        }
      }

      // ===================================================================
      // 4. GUARDADO CON UID DE FIREBASE
      // ===================================================================
      final user = FirebaseAuth.instance.currentUser;
      final horarioId = user?.uid ?? DateTime.now().millisecondsSinceEpoch.toString();

      return Horario(
        id: horarioId, 
        nombre: 'Horario $periodo', 
        estudiante: estudiante,
        periodo: periodo, 
        asignaturas: asignaturasMap.values.toList(), 
        bloques: bloques,
      );
    } catch (e) {
      throw Exception('Error al procesar PDF: $e');
    }
  }
}