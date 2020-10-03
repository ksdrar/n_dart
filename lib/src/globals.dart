class Version {
  bool isActive;
  String path;

  Version(this.isActive, this.path);

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(json['isActive'], json['path']);
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
        for (var entry
            in (json['installedVersions'] as Map<String, dynamic>).entries)
          entry.key: Version.fromJson(entry.value)
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arch': arch,
      'activeVersion': activeVersion,
      'installedVersions': installedVersions
    };
  }
}

String arch;
String nHome;
Config config;
