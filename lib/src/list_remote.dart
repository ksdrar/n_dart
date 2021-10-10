import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:n_dart/colors/colors.dart' as colors;

Future<void> listRemote() async {
  const url = 'https://nodejs.org/dist/index.json';
  final request = await http.get(Uri.parse(url));

  if (request.statusCode != 200) {
    throw Exception('Failed to fetch remote versions.');
  }

  stdout.writeln('Latest version of every major release (since 8):');
  final remoteVersions = json.decode(request.body) as List<dynamic>;
  int major = -1;

  final versions = <String>[];

  for (final entry in remoteVersions) {
    final currentMajor =
        int.parse(entry['version'].substring(1).split('.')[0] as String);

    if (currentMajor < 8) break;

    if (currentMajor == major) {
      continue;
    }

    major = currentMajor;
    final isLTS = entry['lts'] != false;

    versions.add(
      (entry['version'] as String).substring(1) +
          (isLTS ? colors.green(' - LTS') : ''),
    );
  }

  for (final version in versions.reversed) {
    stdout.writeln(version);
  }
}
