class Config {
  String arch;
  String activeVersion;
  Map<String, dynamic> installedVersions;

  Config({this.arch, this.activeVersion, this.installedVersions});

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      arch: json['arch'],
      activeVersion: json['activeVersion'],
      installedVersions: json['installedVersions'],
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
