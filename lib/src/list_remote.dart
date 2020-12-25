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
  final versionIteration = <String, int>{};

  for (final entry in remoteVersions) {
    final major = entry['version'].substring(1).split('.')[0];
    if (int.parse(major) < 8) break;
    if (versionIteration[major] == null) {
      versionIteration[major] = 0;
    }
    if (versionIteration[major] > 2) continue;

    versionIteration[major] += 1;
    final isLTS = entry['lts'] == false ? false : true;

    stdout.writeln(entry['version'].substring(1) +
        (isLTS ? '\x1b[34m - LTS \x1b[0m' : ''));
  }
}
