import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PackDownloaderService {
  Future<File?> downloadPack(
    String url,
    String fileName, {
    void Function(double)? onProgress,
  }) async {
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);
      final contentLength = response.contentLength ?? 0;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      final sink = file.openWrite();

      int received = 0;
      await response.stream.forEach((List<int> chunk) {
        sink.add(chunk);
        received += chunk.length;
        if (contentLength > 0 && onProgress != null) {
          onProgress(received / contentLength);
        }
      });

      await sink.close();
      return file;
    } catch (_) {
      return null;
    }
  }
}
