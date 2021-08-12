import 'dart:io';

import 'package:n_dart/src/globals.dart';
import 'package:path/path.dart' as path;

void setAsActive(String versionNumber) {
  if (config.installedVersions[versionNumber] == null) {
    stdout.writeln('Version $versionNumber is not installed');
    return;
  }

  final symLink = Link(path.join(home, 'bin'));

  // Delete symlink if it already exists
  if (symLink.existsSync()) {
    symLink.deleteSync();
  }

  symLink.createSync(
    path.join(
      config.installedVersions[versionNumber]!.path,
      Platform.isWindows ? '' : 'bin',
    ),
  );

  // If active version is not null, then change that version isActive property
  if (config.activeVersion != '') {
    config.installedVersions[config.activeVersion]!.isActive = false;
  }

  config.installedVersions[versionNumber]!.isActive = true;
  config.activeVersion = versionNumber;
}
