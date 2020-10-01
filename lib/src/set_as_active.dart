import 'dart:io';

import 'package:n_dart/src/globals.dart' as globals;

void setAsActive(String versionNumber) {
  if (globals.config.installedVersions[versionNumber] == null) {
    stdout.writeln('Version $versionNumber is not installed');
    return;
  }

  final symLink = Link(globals.nHome + '/bin');

  // Delete symlink if it already exists
  if (symLink.existsSync()) {
    symLink.deleteSync();
  }

  symLink.createSync(globals.config.installedVersions[versionNumber]['path']);

  // If active version is not null, then change that version isActive property
  if (globals.config.activeVersion != null) {
    globals.config.installedVersions[globals.config.activeVersion]['isActive'] =
        false;
  }

  globals.config.installedVersions[versionNumber]['isActive'] = true;
  globals.config.activeVersion = versionNumber;
}
