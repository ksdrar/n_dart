class Version {
  bool isActive;
  String path;

  Version(this.isActive, this.path);

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(json['isActive'], json['path']);
  }

  Map<String, dynamic> toJson() {
    return {'isActive': isActive, 'path': path};
  }
}

class Config {
  String arch;
  String activeVersion;
  Map<String, Version> installedVersions;

  Config({this.arch, this.activeVersion, this.installedVersions});

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      arch: json['arch'],
      activeVersion: json['activeVersion'],
      installedVersions: <String, Version>{
        for (final entry
            in (json['installedVersions'] as Map<String, dynamic>).entries)
          entry.key: Version.fromJson(entry.value)
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arch': arch,
      'activeVersion': activeVersion,
      'installedVersions': <String, dynamic>{
        for (final entry in (installedVersions.entries))
          entry.key: entry.value.toJson()
      }
    };
  }
}

String arch;
String nHome;
Config config;
