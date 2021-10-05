import 'dart:io';

import 'package:archive/archive.dart';
import 'package:n_dart/src/config.dart' as config;
import 'package:n_dart/src/download_file.dart';
import 'package:n_dart/src/globals.dart';
import 'package:path/path.dart' as path;

Future<void> updateNPM(String versionNumber) async {
  if (config.activeVersion == '') {
    stdout.write('No active node version found');
    return;
  }

  final url = 'https://registry.npmjs.org/npm/-/npm-$versionNumber.tgz';

  try {
    await downloadFile(url, 'npm-$versionNumber.tgz', versionNumber);
  } catch (e) {
    stdout.writeln(e.toString());
    exitCode = 2;
    return;
  }

  final downloadedFile = File(
    path.join(home, '.cache', 'npm-$versionNumber.tgz'),
  );

  stdout.writeln('Extracting file content');
  final gZipDecoder =
      GZipDecoder().decodeBytes(downloadedFile.readAsBytesSync());
  final tarDecoder = TarDecoder().decodeBytes(gZipDecoder);
  final npmPath = path.join(
    config.installedVersions[config.activeVersion]!.path,
    Platform.isWindows ? '' : 'bin',
    'node_modules',
    'npm',
  );
  final npmDirectory = Directory(npmPath);

  if (npmDirectory.existsSync()) {
    npmDirectory.deleteSync(recursive: true);
  }

  for (final file in tarDecoder) {
    file.name = file.name.replaceFirst('package/', '');

    if (file.isFile) {
      File(
        path.join(npmPath, file.name),
      )
        ..createSync(recursive: true)
        ..writeAsBytesSync(file.content as List<int>);
    } else {
      Directory(
        path.join(npmPath, file.name),
      ).createSync(recursive: true);
    }
  }

  stdout.writeln('npm was successfully replaced by version $versionNumber');
}
