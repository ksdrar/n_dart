import 'dart:io';

import 'package:n_dart/src/config.dart' as config;
import 'package:path/path.dart' as path;

void setUp() {
  try {
    config.parseNHome();
  } catch (e) {
    stdout.writeln(e);
    return;
  }

  config.readFromDisk();

  const directories = ['.cache', 'versions'];

  for (final dir in directories) {
    final directory = Directory(path.join(config.home, dir));

    if (!directory.existsSync()) {
      directory.createSync();
    }
  }
}
