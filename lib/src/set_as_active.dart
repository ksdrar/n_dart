import 'dart:io';

import 'package:path/path.dart' as path;

import 'config.dart' as config;

void setAsActive(String version) {
  if (!config.isVersionInstalled(version)) {
    stdout.writeln('Version $version is not installed');
    return;
  }

  final symLink = Link(path.join(config.home, 'bin'));

  // Delete symlink if it already exists
  if (symLink.existsSync()) {
    symLink.deleteSync();
  }

  symLink.createSync(
    path.join(
      config.versionPath(version),
    ),
  );

  config.activeVersion = version;
}
