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

  var url = 'https://nodejs.org/dist/v';
  final downloadName =
      '${'node-v$version-'}${Platform.isWindows ? 'win' : Platform.isLinux ? 'linux' : Platform.isMacOS ? 'darwin' : ''}${'-${config.arch}'}';
  final downloadExtension = Platform.isWindows ? 'zip' : 'tar.xz';

  url += '$version/$downloadName.$downloadExtension';

  List<int> fileBytes;

  // Download file
  try {
    fileBytes = await downloadFile(
      url,
      '$downloadName.$downloadExtension',
      version,
    );
  } catch (e) {
    stdout.writeln(e.toString());
    exitCode = 2;
    return;
  }

  // Extract downloaded file
  try {
    stdout.writeln('Extracting file content');

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
  } catch (e) {
    stdout.writeln(e.toString());
    exitCode = 2;
    return;
  }

  config.installedVersions.add(version);

  if (config.activeVersion == '') {
    stdout.writeln('Setting $version as active version');
    setAsActive(version);
  }

  stdout.writeln('Version $version was successfully installed');
}
