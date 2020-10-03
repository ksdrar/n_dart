import 'dart:convert';
import 'dart:io';

import 'package:n_dart/src/globals.dart' as globals;

Future<void> getConfig() async {
  try {
    final savedConfig = await File(globals.nHome + '/config.json')
        .readAsString()
        .then((sourceString) => jsonDecode(sourceString))
        .then((value) => value);
    globals.config = globals.Config.fromJson(savedConfig);
  } catch (e) {
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
    await saveConfig();
    stdout.write('\n');
  }
}

void saveConfig() {
  try {
    File(globals.nHome + '/config.json')
        .writeAsStringSync(jsonEncode(globals.config.toJson()));
  } catch (e) {
    stdout.writeln('Error writing to ${globals.nHome}/config.json');
  }
}
