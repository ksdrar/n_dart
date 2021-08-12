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
