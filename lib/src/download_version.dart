import 'dart:io';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:n_dart/src/globals.dart' as globals;

Future<void> downloadVersion(String versionNumber) async {
  var url = 'https://nodejs.org/dist/v';
  String downloadName;
  String downloadExtension;

  if (Platform.isWindows) {
    downloadName = 'node-v$versionNumber-win-${globals.config.arch}';
    downloadExtension = 'zip';
  } else if (Platform.isLinux) {
    downloadName = 'node-v$versionNumber-linux-${globals.config.arch}';
    downloadExtension = 'tar.xz';
  } else if (Platform.isMacOS) {
    downloadName = 'node-v$versionNumber-darwin-${globals.config.arch}';
    downloadExtension = 'tar.xz';
  }

  url += '$versionNumber/$downloadName.$downloadExtension';

  if (File(globals.nHome + '/.cache/$downloadName.$downloadExtension')
      .existsSync()) {
    stdout.writeln('Cached file found, using it instead');
    extractFile(versionNumber, downloadName, downloadExtension);
    return;
  }

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

  stdout.writeln(
      'Downloading $downloadName.$downloadExtension ($fileSize), this may take some time.');
  await http.get(url).then(
    (response) {
      stdout.writeln(response.contentLength);
      if (response.statusCode == 200) {
        File(globals.nHome + '/.cache/$downloadName.$downloadExtension')
            .writeAsBytesSync(response.bodyBytes);
      }
    },
  );
  extractFile(versionNumber, downloadName, downloadExtension);
}

void extractFile(
    String versionNumber, String downloadName, String downloadExtension) {
  stdout.writeln('Extracting file content');
  final fileBytes =
      File(globals.nHome + '/.cache/$downloadName.$downloadExtension')
          .readAsBytesSync();
  var fileDecoder;

  switch (downloadExtension) {
    case 'zip':
      fileDecoder = ZipDecoder().decodeBytes(fileBytes);
      break;
    case 'tar.xz':
      fileDecoder = TarDecoder().decodeBytes(fileBytes);
      break;
  }

  for (ArchiveFile file in fileDecoder) {
    if (file.isFile) {
      File(globals.nHome + '/versions/${file.name}')
        ..createSync(recursive: true)
        ..writeAsBytesSync(file.content);
    } else {
      Directory(globals.nHome + '/versions/$file.name')
          .createSync(recursive: true);
    }
  }

  Directory(globals.nHome + '/versions/$downloadName')
      .renameSync(globals.nHome + '/versions/$versionNumber');
}
