import 'package:args/command_runner.dart';
import 'package:n_dart/src/commands.dart';

void main(List<String> args) {
  CommandRunner('n-dart', 'NodeJS version manager')
    ..addCommand(InstallCommand())
    ..addCommand(UninstallCommand())
    ..addCommand(UseCommand())
    ..addCommand(ListCommand())
    ..addCommand(ListRemoteCommand())
    ..addCommand(ReplaceNPMCommand())
    ..run(args);
}
