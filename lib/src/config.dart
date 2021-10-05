import 'dart:convert';
import 'dart:io';

import 'package:n_dart/src/globals.dart';
import 'package:n_dart/src/version.dart';
import 'package:path/path.dart' as path;

String arch = '';
String activeVersion = '';
Map<String, Version> installedVersions = {};

void readUserInput() {
  const validArchitectures = [
    'x64',
    'x86',
    'arm64',
    'armv7l',
    'ppc64le',
    's390x'
  ];

  stdout.writeln('Select your architecture:');
  stdout.writeln(
    validArchitectures
        .map(
          // ignore: prefer_interpolation_to_compose_strings
          (e) => (validArchitectures.indexOf(e) + 1).toString() + ') ' + e,
        )
        .join('\n'),
  );

  var selection = -1;

  while (selection <= 0 || selection > validArchitectures.length) {
    selection = int.parse(stdin.readLineSync()!);
  }

  arch = validArchitectures[selection - 1];
}

void readFromDisk() {
  final file = File(path.join(home, 'config.json'));

  if (!file.existsSync()) {
    readUserInput();
  }

  final fileAsJson = jsonDecode(file.readAsStringSync());

  arch = fileAsJson['arch'] as String;
  activeVersion = fileAsJson['activeVersion'] as String;
  installedVersions = {
    for (final entry
        in (fileAsJson['installedVersions'] as Map<String, dynamic>).entries)
      entry.key: Version.fromJson(entry.value as Map<String, dynamic>)
  };
}

void saveToDisk() {
  try {
    File(path.join(home, 'config.json')).writeAsStringSync(
      jsonEncode(
        {
          'arch': arch,
          'activeVersion': activeVersion,
          'installedVersions': <String, dynamic>{
            for (final entry in installedVersions.entries)
              entry.key: entry.value.toJson()
          }
        },
      ),
    );
  } catch (e) {
    stdout.writeln('Unexpected error while saving config');
  }
}
