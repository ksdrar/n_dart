import 'dart:io';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:n_dart/src/globals.dart' as globals;

Future<void> downloadVersion(String versionNumber) async {
  var url = 'https://nodejs.org/dist/v';
  String fileName;
  String fileExtension;

  if (Platform.isWindows) {
    fileName = 'node-v$versionNumber-win-${globals.config.arch}';
    fileExtension = 'zip';
    url += '$versionNumber/$fileName.$fileExtension';
  } else if (Platform.isLinux) {
    fileName = 'node-v$versionNumber-linux-${globals.config.arch}';
    fileExtension = 'tar.xz';
    url += '$versionNumber/$fileName.$fileExtension';
  } else if (Platform.isMacOS) {
    fileName = 'node-v$versionNumber-darwin-${globals.config.arch}';
    fileExtension = 'tar.xz';
    url += '$versionNumber/$fileName.$fileExtension';
  }

  if (await File(globals.nHome + '/.cache/$fileName.$fileExtension').exists()) {
    stdout.writeln('Cached file found, using it instead');
    extractFile(versionNumber, fileName, fileExtension);
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
        return true;
      }
    },
  );

  stdout.writeln(
      'Downloading $fileName.$fileExtension ($fileSize), this may take some time.');
  await http.get(url).then(
    (response) {
      stdout.writeln(response.contentLength);
      if (response.statusCode == 200) {
        File(globals.nHome + '/.cache/$fileName.$fileExtension')
            .writeAsBytesSync(response.bodyBytes);
      }
    },
  );
  extractFile(versionNumber, fileName, fileExtension);
}

void extractFile(String versionNumber, String fileName, String fileExtension) {
  stdout.writeln('Extracting file content');
  final fileBytes = File(globals.nHome + '/.cache/$fileName.$fileExtension')
      .readAsBytesSync();
  var fileDecoder;

  switch (fileExtension) {
    case 'zip':
      fileDecoder = ZipDecoder().decodeBytes(fileBytes);
      break;
    case 'tar.xz':
      fileDecoder = TarDecoder().decodeBytes(fileBytes);
  }

  for (ArchiveFile file in fileDecoder) {
    var fileName = file.name;
    List<int> data = file.content;

    if (file.isFile) {
      File(globals.nHome + '/versions/$fileName')
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    } else {
      Directory(globals.nHome + '/versions/$fileName')
          .createSync(recursive: true);
    }
  }

  Directory(globals.nHome + '/versions/$fileName')
      .renameSync(globals.nHome + '/versions/$versionNumber');
}
