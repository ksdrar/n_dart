import 'dart:io';

import 'package:archive/archive.dart';
import 'package:n_dart/src/config.dart' as config;
import 'package:n_dart/src/download_file.dart';
import 'package:n_dart/src/set_as_active.dart';
import 'package:path/path.dart' as path;

Future<void> installVersion(String version) async {
  if (config.isVersionInstalled(version)) {
    stdout.writeln('Version $version is already installed');
    return;
  }

  const url = 'https://nodejs.org/dist/v';
  final downloadName = 'node-v$version-win-${config.arch}';
  const downloadExtension = 'zip';

  final fileBytes = await downloadFile(
    '$url$version/$downloadName.$downloadExtension',
    '$downloadName.$downloadExtension',
    version,
  );

  {
    final destinationDir = Directory(path.join(config.home, 'versions', version));

    if (destinationDir.existsSync()) {
      destinationDir.deleteSync();
    }
  }

  stdout.writeln('Extracting file content');

  final fileDecoder = ZipDecoder().decodeBytes(fileBytes);

  for (final file in fileDecoder) {
    if (file.isFile) {
      File(
        path.join(config.home, 'versions', file.name),
      )
        ..createSync(recursive: true)
        ..writeAsBytesSync(file.content as List<int>);
    } else {
      Directory(
        path.join(config.home, 'versions', file.name),
      ).createSync(recursive: true);
    }
  }

  Directory(path.join(config.home, 'versions', downloadName)).renameSync(
    path.join(config.home, 'versions', version),
  );

  config.installedVersions.add(version);

  if (config.activeVersion.isEmpty) {
    stdout.writeln('Setting $version as active version');
    setAsActive(version);
  }

  stdout.writeln('Version $version was successfully installed');
}
