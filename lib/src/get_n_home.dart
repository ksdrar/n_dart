import 'dart:io';

import 'package:n_dart/src/globals.dart' as globals;
import 'package:path/path.dart' as path;

void getNHome() {
  final nHome = Platform.environment['N_HOME'];

  if (nHome == null) {
    globals.nHome = '';
    return;
  }

  globals.nHome = path.canonicalize(
    nHome.replaceAll(
      '~',
      Platform.isWindows ? Platform.environment['USERPROFILE'] : Platform.environment['HOME'],
    ),
  );

  const directories = ['', '.cache', 'versions'];

  for (final dir in directories) {
    if (!Directory(path.join(globals.nHome, dir)).existsSync()) {
      Directory(path.join(globals.nHome, dir)).createSync();
    }
  }
}
