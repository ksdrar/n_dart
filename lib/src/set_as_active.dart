import 'dart:io';

import 'package:n_dart/src/config.dart' as config;
import 'package:path/path.dart' as path;

void setAsActive(String version) {
  if (!config.isVersionInstalled(version)) {
    stdout.writeln('Version $version is not installed');
    return;
  }

  {
    final dir = Directory(path.join(config.home, 'bin'));

    if (dir.existsSync()) {
      dir.deleteSync();
    }
  }

  final symLink = Link(path.join(config.home, 'bin'));

  // Delete symlink if it already exists
  if (symLink.existsSync()) {
    symLink.deleteSync();
  }

  symLink.createSync(path.join(config.versionPath(version)));

  config.activeVersion = version;
}
