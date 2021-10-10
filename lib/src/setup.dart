import 'dart:io';

import 'package:path/path.dart' as path;

import 'config.dart' as config;

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
