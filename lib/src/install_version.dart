import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

import 'config.dart' as config;
import 'download_file.dart';
import 'set_as_active.dart';

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
