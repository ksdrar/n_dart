import 'dart:io';

import 'package:n_dart/src/config.dart' as config;
import 'package:path/path.dart' as path;

void setUp() {
  config.parseNHome();

  config.readFromDisk();

  const directories = ['.cache', 'versions'];

  for (final dir in directories) {
    final directory = Directory(path.join(config.home, dir));

    if (!directory.existsSync()) {
      directory.createSync();
    }
  }
}
