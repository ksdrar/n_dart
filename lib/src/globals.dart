class Version {
  bool isActive;
  String path;

  Version(this.path, {required this.isActive});

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(json['path'] as String, isActive: json['isActive'] as bool);
  }

  Map<String, dynamic> toJson() {
    return {'isActive': isActive, 'path': path};
  }
}

class Config {
  String arch;
  String activeVersion;
  Map<String, Version> installedVersions;

  Config({required this.arch, required this.activeVersion, required this.installedVersions});

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      arch: json['arch'] as String,
      activeVersion: json['activeVersion'] as String,
      installedVersions: <String, Version>{
        for (final entry in (json['installedVersions'] as Map<String, dynamic>).entries)
          entry.key: Version.fromJson(entry.value as Map<String, dynamic>)
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arch': arch,
      'activeVersion': activeVersion,
      'installedVersions': <String, dynamic>{
        for (final entry in installedVersions.entries) entry.key: entry.value.toJson()
      }
    };
  }
}

String arch = '';
String nHome = '';
Config config = Config(arch: '', activeVersion: '', installedVersions: {});
