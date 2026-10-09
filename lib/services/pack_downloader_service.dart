import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';

class PackDownloaderService {
  static Future<bool> isPackDownloaded(String langCode) async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File('${dir.path}/packs/$langCode/$langCode-1.0.0.sqlite');
    return await dbFile.exists();
  }

  static Future<void> downloadAndInstallPack(String langCode, String url, Function(double) onProgress) async {
    final dir = await getApplicationDocumentsDirectory();
    final packDir = Directory('${dir.path}/packs/$langCode');
      await packDir.create(recursive: true);
    }
    final gzFile = File('${packDir.path}/pack.gz');
    final request = http.Request('GET', Uri.parse(url));
    final response = await http.Client().send(request);
    final contentLength = response.contentLength ?? 0;
    int downloadedBytes = 0;
    final sink = gzFile.openWrite();
    await response.stream.forEach((chunk) {
      sink.add(chunk);
      downloadedBytes += chunk.length;
      if (contentLength > 0) {
        double progress = downloadedBytes / contentLength;
        onProgress(progress);
      }
    });
    await sink.flush();
    await sink.close();
    final bytes = await gzFile.readAsBytes();
    final decodedBytes = const GZipDecoder().decodeBytes(bytes);
    final dbFile = File('${packDir.path}/$langCode-1.0.0.sqlite');
    await dbFile.writeAsBytes(decodedBytes);
    if (await gzFile.exists()) {
      await gzFile.delete();
    }
  }
}