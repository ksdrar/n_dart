import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:n_dart/src/globals.dart' as globals;

class FileNotAvailable implements Exception {
  FileNotAvailable(String s);
}

class DownloadError implements Exception {
  DownloadError(String s);
}

Future<void> downloadFile(String url, String fileName, String version) async {
  final file = File(globals.nHome + '/.cache/$fileName');

  if (file.existsSync()) {
    stdout.writeln('Cached file found.');
    return;
  }

  var response = await http.head(url);

  if (response.statusCode == 404) {
    throw FileNotAvailable(
        'Version $version is not available or does not exist');
  } else if (response.statusCode != 200) {
    throw DownloadError('Unexpected error while downloading, try again later');
  }

  stdout.writeln(
      'Downloading $fileName (${(int.parse(response.headers['content-length']) / 1e+6).toStringAsFixed(2)} MB)');
  response = await http.get(url);

  if (response.statusCode == 404) {
    throw FileNotAvailable(
        'Version $version is not available or does not exist');
  } else if (response.statusCode != 200) {
    throw DownloadError('Unexpected error while downloading, try again later');
  }

  file.writeAsBytesSync(response.bodyBytes);
}
