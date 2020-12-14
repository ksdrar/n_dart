import 'dart:io';

import 'package:archive/archive.dart';
import 'package:n_dart/src/download_file.dart';
import 'package:n_dart/src/globals.dart' as globals;
import 'package:n_dart/src/set_as_active.dart';
import 'package:path/path.dart' as path;

Future<void> installVersion(String versionNumber) async {
  if (globals.config.installedVersions.containsKey(versionNumber)) {
    stdout.writeln('Version $versionNumber is already installed');
    return;
  }

  var url = 'https://nodejs.org/dist/v';
  final downloadName = 'node-v$versionNumber-' +
      (Platform.isWindows
          ? 'win'
          : Platform.isLinux
              ? 'linux'
              : Platform.isMacOS
                  ? 'darwin'
                  : '') +
      '-${globals.config.arch}';
  final downloadExtension = Platform.isWindows ? 'zip' : 'tar.xz';

  url += '$versionNumber/$downloadName.$downloadExtension';

  // Download file
  try {
    await downloadFile(url, '$downloadName.$downloadExtension', versionNumber);
  } catch (e) {
    stdout.writeln(e.toString());
    exitCode = 2;
    return;
  }

  // Extract downloaded file
  try {
    stdout.writeln('Extracting file content');
    final fileBytes = File(
      path.join(globals.nHome, '.cache', '$downloadName.$downloadExtension'),
    ).readAsBytesSync();
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
        File(
          path.join(globals.nHome, 'versions', file.name),
        )
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content);
      } else {
        Directory(
          path.join(globals.nHome, 'versions', file.name),
        ).createSync(recursive: true);
      }
    }

    Directory(path.join(globals.nHome, 'versions', downloadName)).renameSync(
      path.join(globals.nHome, 'versions', versionNumber),
    );
  } catch (e) {
    stdout.writeln(e.toString());
    exitCode = 2;
    return;
  }

  globals.config.installedVersions[versionNumber] = globals.Version(
    globals.config.activeVersion == null ? true : false,
    path.join(globals.nHome, 'versions', versionNumber),
  );

  if (globals.config.activeVersion == null) {
    stdout.writeln('Setting $versionNumber as active version');
    setAsActive(versionNumber);
  }

  stdout.writeln('Version $versionNumber was successfully installed');
}
