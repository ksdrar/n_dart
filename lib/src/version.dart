class Version {
  String path;

  Version(this.path);

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(json['path'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'path': path};
  }
}
