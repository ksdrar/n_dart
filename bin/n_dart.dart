import 'dart:io';

import 'package:n_dart/src/config_handler.dart';
import 'package:n_dart/src/get_n_home.dart';
import 'package:n_dart/src/globals.dart' as globals;
import 'package:n_dart/src/install_version.dart';
import 'package:n_dart/src/list_remote.dart';
import 'package:n_dart/src/set_as_active.dart';
import 'package:n_dart/src/uninstall_version.dart';
import 'package:n_dart/src/update_npm.dart';

Future<void> main(List<String> arguments) async {
  getNHome();

  if (globals.nHome == '') {
    print('N_HOME is not defined');
    exitCode = 1;
    return;
  }

  if (arguments.isEmpty) {
    printHelp();
    return;
  }

  await getConfig();

  switch (arguments[0]) {
    case 'i':
    case 'install':
      await installVersion(arguments[1]);
      await saveConfig();
      break;
    case 'un':
    case 'uninstall':
      await uninstallVersion(arguments[1]);
      await saveConfig();
      break;
    case 'use':
      if (!globals.config.installedVersions.containsKey(arguments[1])) {
        stdout.writeln('Version ${arguments[1]} is not installed');
        break;
      } else if (arguments[1] == globals.config.activeVersion) {
        stdout.writeln('Version ${arguments[1]} is already active');
        break;
      }

      await setAsActive(arguments[1]);
      await saveConfig();
      break;
    case 'ls':
    case 'list-local':
      stdout.writeln('Installed versions:');
      final versionsList = [
        for (final entry in globals.config.installedVersions.entries)
          entry.key + (entry.value.isActive ? ' - active' : '')
      ];
      versionsList.sort();

      for (final version in versionsList) {
        stdout.writeln(version);
      }

      break;
    case 'lsr':
    case 'list-remote':
      await listRemote();
      break;
    case 'update-npm':
      await updateNPM(arguments[1]);
      break;
    case '--h':
    case '--help':
    case 'help':
      printHelp();
      break;
    default:
      stdout.writeln('Command ${arguments[0]} is not valid');
      break;
  }
}

void printHelp() {
  const help = 'Usage: n_dart <command>\n\n'
      'n_dart install <version>     install the selected NodeJS version\n'
      'n_dart uninstall <version>   remove the selected NodeJS version\n'
      'n_dart use <version>         change the active version to the selected one\n'
      'n_dart list-local            list installed versions\n'
      'n_dart list-remote           list last 3 releases of major NodeJS versions\n'
      'n_dart update-npm <version>  update npm version of active NodeJS version\n';
  stdout.writeln(help);
}
