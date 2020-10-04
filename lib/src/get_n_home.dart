import 'dart:io';

import 'package:n_dart/src/globals.dart' as globals;

void getNHome() {
  final nHome = Platform.environment['N_HOME'];

  if (nHome == null) {
    globals.nHome = '';
    return;
  }

  globals.nHome = nHome
      .replaceAll(
          '~',
          Platform.isLinux || Platform.isMacOS
              ? Platform.environment['HOME']
              : Platform.environment['USERPROFILE'])
      .replaceAll('\\', '/');

  if (!Directory(nHome).existsSync()) {
    Directory(nHome).createSync();
  }

  if (Directory(nHome + '/.cache').existsSync()) {
    Directory(nHome + '/.cache').createSync();
  }

  if (Directory(nHome + '/versions').existsSync()) {
    Directory(nHome + '/versions').createSync();
  }
}
