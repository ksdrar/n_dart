import 'dart:io';

import 'package:archive/archive.dart';
import 'package:n_dart/src/download_file.dart';
import 'package:n_dart/src/globals.dart' as globals;
import 'package:n_dart/src/set_as_active.dart';

Future<void> installVersion(String versionNumber) async {
  if (globals.config.installedVersions.containsKey(versionNumber)) {
    stdout.writeln('Version $versionNumber is already installed');
    return;
  }

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

  try {
    await downloadFile(url, '$downloadName.$downloadExtension', versionNumber);
  } on DownloadError catch (e) {
    stdout.writeln(e);
    exitCode = 2;
    return;
  } on FileNotAvailable catch (e) {
    stdout.writeln(e);
    exitCode = 2;
    return;
  }
  ;

  extractFile(versionNumber, downloadName, downloadExtension);

  if (!Directory(globals.nHome + '/versions/$versionNumber').existsSync()) {
    stdout.writeln('Unexpected error installing $versionNumber');
    exitCode = 2;
    return;
  }

  globals.config.installedVersions[versionNumber] = globals.Version(
    globals.config.activeVersion == null ? true : false,
    globals.nHome + '/versions/$versionNumber',
  );

  if (globals.config.activeVersion == null) {
    stdout.writeln('Setting $versionNumber as active version');
    setAsActive(versionNumber);
  }

  stdout.writeln('Version $versionNumber was successfully installed');
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
