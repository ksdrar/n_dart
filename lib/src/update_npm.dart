import 'dart:io';

import 'package:archive/archive.dart';
import 'package:n_dart/src/download_file.dart';
import 'package:n_dart/src/globals.dart' as globals;

Future<void> updateNPM(String versionNumber) async {
  final url = 'https://registry.npmjs.org/npm/-/npm-${versionNumber}.tgz';

  try {
    await downloadFile(url, 'npm-${versionNumber}.tgz', versionNumber);
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

  final downloadedFile =
      File(globals.nHome + '/.cache/npm-${versionNumber}.tgz');

  stdout.writeln('Extracting file content');
  final gZipDecoder =
      GZipDecoder().decodeBytes(downloadedFile.readAsBytesSync());
  final tarDecoder = TarDecoder().decodeBytes(gZipDecoder);
  final npmPath =
      globals.config.installedVersions[globals.config.activeVersion].path +
          (Platform.isMacOS || Platform.isLinux ? '/lib/' : '') +
          '/node_modules/npm';
  final npmDirectory = Directory(npmPath);

  if (npmDirectory.existsSync()) {
    npmDirectory.deleteSync(recursive: true);
  }

  for (final file in tarDecoder) {
    if (file.isFile) {
      File(npmPath + '/../${file.name}')
        ..createSync(recursive: true)
        ..writeAsBytesSync(file.content);
    } else {
      Directory(npmPath + '/../$file.name').createSync(recursive: true);
    }
  }

  Directory(npmPath + '/../package').renameSync(npmPath);
  stdout.writeln('npm was successfully updated/downgraded to $versionNumber');
}
