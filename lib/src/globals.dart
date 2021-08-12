import 'dart:io';

import 'package:n_dart/src/config.dart';

String arch = '';
final home = Platform.environment['N_HOME']!;
final config = Config.loadFromDisk();
