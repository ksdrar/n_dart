import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> listRemote() async {
  const url =
      'https://gist.githubusercontent.com/itsje/75ebde8ed9555ca9f68312111b2d433e/raw';
  final request = await http.get(url);

  if (request.statusCode != 200) {
    print('Unexpected error fetching remote versions');
    return;
  }

  stdout.writeln('Last 3 releases of major NodeJS versions');
  final remoteVersions =
      (json.decode(request.body) as List<dynamic>).cast<String>();

  for (final version in remoteVersions) {
    print(version);
  }
}
