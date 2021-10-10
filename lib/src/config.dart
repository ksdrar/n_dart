import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

String home = '';
String arch = '';
String activeVersion = '';
List<String> installedVersions = [];

void parseNHome() {
  if (Platform.environment['N_HOME'] == null) {
    throw Exception('N_HOME is not defined');
  }

  home = Platform.environment['N_HOME']!;
}

bool isVersionInstalled(String version) => installedVersions.contains(version);

String versionPath(String version) => path.join(home, 'versions', version);

void _readUserInput() {
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

  saveToDisk();
}

void readFromDisk() {
  final file = File(path.join(home, 'config.json'));

  if (!file.existsSync()) {
    _readUserInput();
  }

  final fileAsJson = jsonDecode(file.readAsStringSync());

  arch = fileAsJson['arch'] as String;
  activeVersion = fileAsJson['activeVersion'] as String;
  installedVersions =
      List.castFrom<dynamic, String>(fileAsJson['installedVersions'] as List);
}

void saveToDisk() {
  try {
    File(path.join(home, 'config.json')).writeAsStringSync(
      jsonEncode(
        {
          'arch': arch,
          'activeVersion': activeVersion,
          'installedVersions': installedVersions
        },
      ),
    );
  } catch (e) {
    stdout.writeln('Unexpected error while saving config');
  }
}
