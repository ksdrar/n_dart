import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:n_dart/src/config.dart' as config;
import 'package:n_dart/src/install_version.dart';
import 'package:n_dart/src/list_remote.dart';
import 'package:n_dart/src/set_as_active.dart';
import 'package:n_dart/src/uninstall_version.dart';
import 'package:n_dart/src/update_npm.dart';

class InstallCommand extends Command {
  @override
  String get description => 'Installs the typed NodeJS version';

  @override
  String get invocation => 'install <version>';

  @override
  String get name => 'install';

  @override
  List<String> get aliases => ['i'];

  @override
  Future<void> run() async {
    await installVersion(argResults!.rest[0]);
    config.saveToDisk();
  }
}

class UninstallCommand extends Command {
  @override
  String get description => 'Uninstalls the typed NodeJS version';

  @override
  String get invocation => 'uninstall <version>';

  @override
  String get name => 'uninstall';

  @override
  List<String> get aliases => ['un'];

  @override
  void run() {
    uninstallVersion(argResults!.rest[0]);
    config.saveToDisk();
  }
}

class UseCommand extends Command {
  @override
  String get description => 'Makes the typed NodeJS version the active one';

  @override
  String get invocation => 'use <version>';

  @override
  String get name => 'use';

  @override
  void run() {
    if (!config.installedVersions.containsKey(argResults!.rest[0])) {
      stdout.writeln('Version ${argResults!.rest[0]} is not installed');
      return;
    } else if (argResults!.rest[0] == config.activeVersion) {
      stdout.writeln('Version ${argResults!.rest[0]} is already active');
      return;
    }

    setAsActive(argResults!.rest[0]);
    config.saveToDisk();
  }
}

class ListCommand extends Command {
  @override
  String get description => 'Outputs a list of the installed NodeJS versions';

  @override
  String get name => 'list';

  @override
  List<String> get aliases => ['ls'];

  @override
  void run() {
    stdout.writeln('Installed versions:');
    final versionsList = [
      for (final entry in config.installedVersions.entries)
        entry.key + (entry.key == config.activeVersion ? ' - active' : '')
    ];
    versionsList.sort();

    for (final version in versionsList) {
      stdout.writeln(version);
    }
  }
}

class ListRemoteCommand extends Command {
  @override
  String get description => 'Outputs a list of the available NodeJS versions';

  @override
  String get name => 'list-remote';

  @override
  List<String> get aliases => ['lsr'];

  @override
  Future<void> run() async {
    await listRemote();
  }
}

class ReplaceNPMCommand extends Command {
  @override
  String get description =>
      'Replaces the installed npm version with the one typed';

  @override
  String get invocation => 'replace-npm <version>';

  @override
  String get name => 'replace-npm';

  @override
  List<String> get aliases => ['r-npm'];

  @override
  Future<void> run() async {
    await updateNPM(argResults!.rest[0]);
  }
}
