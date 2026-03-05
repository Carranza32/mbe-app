import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Guarda bytes en un archivo en el directorio de documentos de la app
/// (o descargas si está disponible). Retorna la ruta absoluta del archivo.
/// [filename] ej: pre-alertas-2025-02-25-143022.xlsx
Future<String> saveExportFile({
  required List<int> bytes,
  required String filename,
}) async {
  Directory dir;
  try {
    // Intentar directorio de descargas (Android/iOS puede tener restricciones)
    dir = await getApplicationDocumentsDirectory();
  } catch (_) {
    dir = Directory.systemTemp;
  }

  final path = '${dir.path}/$filename';
  final file = File(path);
  await file.writeAsBytes(bytes);
  return path;
}
