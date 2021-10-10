import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> listRemote() async {
  const url = 'https://nodejs.org/dist/index.json';
  final request = await http.get(Uri.parse(url));

  if (request.statusCode != 200) {
    stdout.writeln('Unexpected error fetching remote versions');
    return;
  }

  stdout.writeln('Latest version of every major release (since 8):');
  final remoteVersions = json.decode(request.body) as List<dynamic>;
  var major = -1;

  for (final entry in remoteVersions) {
    final currentMajor =
        int.parse(entry['version'].substring(1).split('.')[0] as String);

    if (currentMajor < 8) continue;

    if (currentMajor == major) {
      continue;
    }

    major = currentMajor;
    final isLTS = entry['lts'] != false;
    stdout.writeln(
      entry['version'].substring(1) + (isLTS ? '\x1b[34m - LTS \x1b[0m' : ''),
    );
  }
}
