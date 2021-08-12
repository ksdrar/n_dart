import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:n_dart/src/globals.dart' as globals;
import 'package:path/path.dart' as path;

class FileNotAvailable implements Exception {
  String message;

  FileNotAvailable(this.message);

  @override
  String toString() {
    return message;
  }
}

class DownloadError implements Exception {
  String message;

  DownloadError(this.message);

  @override
  String toString() {
    return message;
  }
}

Future<void> downloadFile(String url, String fileName, String version) async {
  final file = File(path.join(globals.nHome, '.cache', fileName));

  if (file.existsSync()) {
    stdout.writeln('Cached file found.');
    return;
  }

  var response = await http.head(Uri.parse(url));

  if (response.statusCode == 404) {
    throw FileNotAvailable('Version $version is not available or does not exist');
  } else if (response.statusCode != 200) {
    throw DownloadError('Unexpected error while downloading, try again later');
  }

  // ignore: prefer_interpolation_to_compose_strings
  stdout.writeln('Downloading $fileName ' +
      (response.headers['content-length'] == null
          ? ''
          : '${(int.parse(response.headers['content-length']) / 1e+6).toStringAsFixed(2)} MB)'));

  response = await http.get(Uri.parse(url));

  if (response.statusCode == 404) {
    throw FileNotAvailable('Version $version is not available or does not exist');
  } else if (response.statusCode != 200) {
    throw DownloadError('Unexpected error while downloading, try again later');
  }

  file.writeAsBytesSync(response.bodyBytes);
}
