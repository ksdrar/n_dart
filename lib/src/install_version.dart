import 'dart:io';

import 'package:n_dart/src/download_version.dart';
import 'package:n_dart/src/globals.dart' as globals;
import 'package:n_dart/src/set_as_active.dart';

void installVersion(String versionNumber) async {
  if (globals.config.installedVersions[versionNumber] != null) {
    stdout.writeln('Version $versionNumber is already installed');
    return;
  }

  await downloadVersion(versionNumber);

  if (!Directory(globals.nHome + '/versions/$versionNumber').existsSync()) {
    stdout.writeln('Unexpected error installing $versionNumber');
    return;
  }

  globals.config.installedVersions[versionNumber] = globals.Version(
      globals.config.activeVersion == null ? true : false,
      globals.nHome + '/versions/$versionNumber');

  if (globals.config.activeVersion == null) {
    stdout.writeln('Setting $versionNumber as active version');
    setAsActive(versionNumber);
  }

  stdout.writeln('Version $versionNumber was successfully installed');
}
