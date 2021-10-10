import 'dart:io';

import 'config.dart' as config;

void uninstallVersion(String version) {
  if (!config.isVersionInstalled(version)) {
    stdout.writeln('Version $version is not installed');
    return;
  } else if (config.activeVersion == version) {
    stdout.writeln(
      'Version $version is the current active version, change it before uninstalling it',
    );
    return;
  }

  Directory(config.versionPath(version)).deleteSync(recursive: true);
  config.installedVersions.remove(version);
  stdout.writeln('Version $version was successfully uninstalled');
}
