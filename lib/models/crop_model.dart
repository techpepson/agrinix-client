class CropModel {
  CropModel({required this.cropImageUrl, this.token});
  String cropImageUrl;
  String? token;

  CropModel copyWith({String? cropImageUrl, String? token}) {
    return CropModel(
      cropImageUrl: cropImageUrl ?? this.cropImageUrl,
      token: token ?? this.token,
    );
  }

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(cropImageUrl: json['cropImage'], token: json['token']);
  }

  Map<String, dynamic> toJson() {
    return {'cropImage': cropImageUrl.trim(), 'token': token?.trim()};
  }
}
