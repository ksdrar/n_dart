import 'dart:io';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:n_dart/src/globals.dart' as globals;

Future<void> updateNPM(String versionNumber) async {
  final url = 'https://registry.npmjs.org/npm/-/npm-${versionNumber}.tgz';
  String fileSize;

  await http.head(url).then(
    (response) {
      if (response.statusCode != 200) {
        stdout.writeln(
            'Version $versionNumber doesn\'t exist or is not available');
        exit(2);
      } else {
        fileSize = (int.parse(response.headers['content-length']) / 1e+6)
                .toStringAsFixed(2) +
            ' MB';
      }
    },
  );

  final downloadedFile =
      File(globals.nHome + '/.cache/npm-${versionNumber}.tgz');

  if (downloadedFile.existsSync()) {
    stdout.writeln('Cached file found, using it instead');
  } else {
    stdout.writeln(
        'Downloading npm-${versionNumber}.tgz ($fileSize), this may take some time.');
    await http.get(url).then(
      (response) {
        stdout.writeln(response.contentLength);
        if (response.statusCode == 200) {
          downloadedFile.writeAsBytesSync(response.bodyBytes);
        }
      },
    );
  }

  final downloadedFileBytes = downloadedFile.readAsBytesSync();
  final tgzDecoder = GZipDecoder().decodeBytes(downloadedFileBytes);
  final activePath =
      globals.config.installedVersions[globals.config.activeVersion]['path'];
  final fileDecoder = TarDecoder().decodeBytes(tgzDecoder);

  final npmDirectory = Directory(activePath + '/node_modules/npm');

  if (npmDirectory.existsSync()) {
    npmDirectory.deleteSync(recursive: true);
  }

  for (var file in fileDecoder) {
    var fileName = file.name;
    List<int> data = file.content;

    if (file.isFile) {
      File(activePath + '/node_modules/$fileName')
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    } else {
      Directory(activePath + '/node_modules/$fileName')
          .createSync(recursive: true);
    }
  }

  Directory(activePath + '/node_modules/package')
      .renameSync(activePath + '/node_modules/npm');

  stdout.writeln('npm was successfully updated/downgraded to $versionNumber');
}
