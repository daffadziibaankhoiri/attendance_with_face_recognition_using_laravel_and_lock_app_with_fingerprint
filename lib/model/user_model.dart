class UserModel {
  String? nama;
  String? password;
  String? image;
  List<FeaturePoint>? faceFeatures;

  UserModel({
    this.nama,
    this.password,
    this.image,
    this.faceFeatures,
  });
  @override
  String toString() {
    return 'UserModel{name: $nama, password: $password, image: $image, faceFeatures: $faceFeatures}';
  }
  factory UserModel.fromJson(Map<String, dynamic> json) {
    var featuresList = json["face_features"] as List;
    List<FeaturePoint> features = featuresList.map((i) => FeaturePoint.fromJson(i)).toList();

    return UserModel(
      nama: json['nama'],
      password: json['password'],
      image: json['image'],
      faceFeatures: features,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'password' : password,
      'image': image,
      'face_features': faceFeatures?.map((f) => f.toJson()).toList() ?? [],
    };
  }
}

class FeaturePoint {
  String? featureName;
  Points? points;

  FeaturePoint({this.featureName, this.points});

  factory FeaturePoint.fromJson(Map<String, dynamic> json) {
    return FeaturePoint(
      featureName: json['feature_name'],
      points: Points.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    // Periksa apakah `points` bukan null sebelum mencoba mengakses `x` dan `y`
    assert(points != null, 'Points cannot be null');
    return {
      'feature_name': featureName,
      'x': points!.x,
      'y': points!.y,
    };
  }
}

class Points {
  int? x;
  int? y;

  Points({
    required this.x,
    required this.y,
  });

  factory Points.fromJson(Map<String, dynamic> json) => Points(
    x: json['x'] as int?,
    y: json['y'] as int?,
  );

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
}
