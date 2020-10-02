import 'dart:io';

import 'package:n_dart/src/globals.dart' as globals;

void uninstallVersion(String versionNumber) {
  if (globals.config.installedVersions[versionNumber] == null) {
    stdout.writeln('Version $versionNumber is not installed');
    return;
  } else if (globals.config.activeVersion == versionNumber) {
    stdout.writeln(
        'Version $versionNumber is the current active version, change it before uninstalling it');
    return;
  }

  Directory(globals.config.installedVersions[versionNumber]['path'])
      .deleteSync(recursive: true);
  globals.config.installedVersions.remove(versionNumber);
  stdout.writeln('Version $versionNumber was successfully uninstalled');
}
