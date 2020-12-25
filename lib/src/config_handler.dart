import 'dart:convert';
import 'dart:io';

import 'package:n_dart/src/globals.dart' as globals;
import 'package:path/path.dart' as path;

Future<void> getConfig() async {
  final savedConfig = File(path.join(globals.nHome, 'config.json'));

  if (await savedConfig.exists()) {
    globals.config = globals.Config.fromJson(
        jsonDecode(await savedConfig.readAsString()) as Map<String, dynamic>);
    return;
  }

  stdout.writeln('Type the architecture you want to use\n'
      'List of available architectures: '
      'x86, x64, arm64*, armv7l*, ppc64le*, s390x*'
      '\n\n*Linux only');
  final validArchitectures = [
    'x86',
    'x64',
    'arm64',
    'armv7l',
    'ppc64le',
    's390x'
  ];
  var arch = '';
  while (!validArchitectures.contains(arch)) {
    arch = stdin.readLineSync();

    if (!validArchitectures.contains(arch)) {
      stdout.writeln('$arch is not a valid input, try again.');
    }
  }

  globals.config = globals.Config(arch: arch, installedVersions: {});
  saveConfig();
  stdout.write('\n');
}

void saveConfig() {
  try {
    File(path.join(globals.nHome, 'config.json'))
        .writeAsStringSync(jsonEncode(globals.config.toJson()));
  } catch (e) {
    stdout
        .writeln('Error writing to ${path.join(globals.nHome, 'config.json')}');
  }
}
