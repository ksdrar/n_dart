import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:n_dart/src/globals.dart';
import 'package:path/path.dart' as path;

Future<List<int>> downloadFile(
  String url,
  String fileName,
  String version,
) async {
  final file = File(path.join(home, '.cache', fileName));

  if (file.existsSync()) {
    stdout.writeln('Cached file found.');
    return file.readAsBytes();
  }

  final client = http.Client();
  final streamedResponse =
      await client.send(http.Request('GET', Uri.parse(url)));

  if (streamedResponse.statusCode == 404) {
    throw Exception('Version $version is not available or does not exist');
  } else if (streamedResponse.statusCode != 200) {
    throw Exception('Unexpected error while downloading, try again later');
  }

  stdout.writeln(
    'Downloading $fileName (${(streamedResponse.contentLength! / 1e+6).toStringAsFixed(2)} MB)',
  );

  final bytes = await streamedResponse.stream.toBytes();

  await file.writeAsBytes(bytes);

  client.close();

  return bytes;
}
