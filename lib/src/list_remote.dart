import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> listRemote() async {
  const url = 'https://nodejs.org/dist/index.json';
  final request = await http.get(url);

  if (request.statusCode != 200) {
    print('Unexpected error fetching remote versions');
    return;
  }

  stdout.writeln('Last 3 releases of major NodeJS versions: \n');
  final remoteVersions = (json.decode(request.body) as List<dynamic>);
  final versions = parseIndexJSON(remoteVersions);

  for (final entry in versions) {
    stdout.writeln(entry);
  }
}

List<String> parseIndexJSON(List<dynamic> indexJSON) {
  final versionMap = <String, int>{};
  final versionList = <String>[];

  for (final entry in indexJSON) {
    final version = entry['version'] as String;
    final major = version.split('.')[0];
    final isLTS = entry['lts'] == false ? false : true;

    if (int.parse(major.substring(1)) < 8) {
      break;
    }

    if (versionMap[major] == null) {
      versionMap[major] = 1;
    }

    if (versionMap[major] <= 3) {
      versionMap[major] += 1;
      versionList.add(version.substring(1) + (isLTS ? ' - LTS' : ''));
    }
  }

  return versionList;
}
