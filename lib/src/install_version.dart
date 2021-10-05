import 'dart:io';

import 'package:archive/archive.dart';
import 'package:n_dart/src/config.dart' as config;
import 'package:n_dart/src/download_file.dart';
import 'package:n_dart/src/globals.dart';
import 'package:n_dart/src/set_as_active.dart';
import 'package:n_dart/src/version.dart';
import 'package:path/path.dart' as path;

Future<void> installVersion(String versionNumber) async {
  if (config.installedVersions.containsKey(versionNumber)) {
    stdout.writeln('Version $versionNumber is already installed');
    return;
  }

  var url = 'https://nodejs.org/dist/v';
  final downloadName =
      '${'node-v$versionNumber-'}${Platform.isWindows ? 'win' : Platform.isLinux ? 'linux' : Platform.isMacOS ? 'darwin' : ''}${'-${config.arch}'}';
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
      path.join(home, '.cache', '$downloadName.$downloadExtension'),
    ).readAsBytesSync();

    Archive fileDecoder;

    switch (downloadExtension) {
      case 'zip':
        fileDecoder = ZipDecoder().decodeBytes(fileBytes);
        break;
      case 'tar.xz':
        fileDecoder = TarDecoder().decodeBytes(fileBytes);
        break;
      default:
        stdout.write(
          "Failed to extract contents. Error: file extension doesn't match",
        );
        return;
    }

    for (final file in fileDecoder) {
      if (file.isFile) {
        File(
          path.join(home, 'versions', file.name),
        )
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content as List<int>);
      } else {
        Directory(
          path.join(home, 'versions', file.name),
        ).createSync(recursive: true);
      }
    }

    Directory(path.join(home, 'versions', downloadName)).renameSync(
      path.join(home, 'versions', versionNumber),
    );
  } catch (e) {
    stdout.writeln(e.toString());
    exitCode = 2;
    return;
  }

  config.installedVersions[versionNumber] =
      Version(path.join(home, 'versions', versionNumber));

  if (config.activeVersion == '') {
    stdout.writeln('Setting $versionNumber as active version');
    setAsActive(versionNumber);
  }

  stdout.writeln('Version $versionNumber was successfully installed');
}
