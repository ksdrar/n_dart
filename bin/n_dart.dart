import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:n_dart/src/commands.dart';

Future<void> main(List<String> args) async {
  final commandRunner = CommandRunner('n-dart', 'NodeJS version manager')
    ..addCommand(InstallCommand())
    ..addCommand(UninstallCommand())
    ..addCommand(UseCommand())
    ..addCommand(ListCommand())
    ..addCommand(ListRemoteCommand())
    ..addCommand(ReplaceNPMCommand());

  commandRunner.run(args).catchError((err) {
    if (err is! UsageException) throw err as Object;

    stdout.writeln(err);
  });
}
