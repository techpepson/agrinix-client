class CropPestModel {
  CropPestModel({
    required this.id,
    required this.commonName,
    required this.description,
    required this.host,
    required this.images,
    required this.scientificName,
    required this.solution,
  });

  dynamic id;
  String commonName;
  String scientificName;
  List<Map<String, dynamic>> description;
  List<Map<String, dynamic>> solution;
  String host;
  List<Map<String, dynamic>> images;

  CropPestModel copyWith({
    String? id,
    String? commonName,
    List<Map<String, dynamic>>? description,
    List<Map<String, dynamic>>? solution,
    String? host,
    List<Map<String, dynamic>>? images,
    String? scientificName,
  }) {
    return CropPestModel(
      id: id ?? this.id,
      commonName: commonName ?? this.commonName,
      description: description ?? this.description,
      host: host ?? this.host,
      images: images ?? this.images,
      scientificName: scientificName ?? this.scientificName,
      solution: solution ?? this.solution,
    );
  }

  factory CropPestModel.fromJson(Map<String, dynamic> json) {
    return CropPestModel(
      id: json['id'],
      commonName: json['commonName'],
      description: List<Map<String, dynamic>>.from(json['description'] ?? []),
      host: json['host'],
      images: List<Map<String, dynamic>>.from(json['images'] ?? []),
      scientificName: json['scientificName'],
      solution: List<Map<String, dynamic>>.from(json['solution'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commonName': commonName,
      'description': description,
      'host': host,
      'images': images,
      'scientificName': scientificName,
      'solution': solution,
    };
  }
}
