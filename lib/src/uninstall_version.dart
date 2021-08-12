import 'dart:io';

import 'package:n_dart/src/globals.dart';

void uninstallVersion(String versionNumber) {
  if (config.installedVersions[versionNumber] == null) {
    stdout.writeln('Version $versionNumber is not installed');
    return;
  } else if (config.activeVersion == versionNumber) {
    stdout.writeln(
        'Version $versionNumber is the current active version, change it before uninstalling it');
    return;
  }

  Directory(config.installedVersions[versionNumber]!.path).deleteSync(recursive: true);
  config.installedVersions.remove(versionNumber);
  stdout.writeln('Version $versionNumber was successfully uninstalled');
}
