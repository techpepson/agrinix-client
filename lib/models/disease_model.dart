class DiseaseModel {
  DiseaseModel({
    required this.inferenceId,
    required this.confidence,
    required this.detectionDescription,
    required this.diseaseCauses,
    required this.diseaseClass,
    required this.diseaseSymptoms,
    required this.diseaseTreatment,
    required this.source,
  });

  String inferenceId;
  String diseaseClass;
  int confidence;
  String detectionDescription;
  List<String> diseaseCauses;
  List<String> diseaseSymptoms;
  List<String> diseaseTreatment;
  String source;

  DiseaseModel copyWith({
    String? inferenceId,
    String? diseaseClass,
    int? confidence,
    String? detectionDescription,
    List<String>? diseaseCauses,
    List<String>? diseaseSymptoms,
    List<String>? diseaseTreatment,
    String? source,
  }) {
    return DiseaseModel(
      inferenceId: inferenceId ?? this.inferenceId,
      diseaseClass: diseaseClass ?? this.diseaseClass,
      confidence: confidence ?? this.confidence,
      detectionDescription: detectionDescription ?? this.detectionDescription,
      diseaseCauses: diseaseCauses ?? List<String>.from(this.diseaseCauses),
      diseaseSymptoms:
          diseaseSymptoms ?? List<String>.from(this.diseaseSymptoms),
      diseaseTreatment:
          diseaseTreatment ?? List<String>.from(this.diseaseTreatment),
      source: source ?? this.source,
    );
  }

  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      inferenceId: json['inferenceId'] as String,
      diseaseClass: json['diseaseClass'] as String,
      confidence:
          json['confidence'] is int
              ? json['confidence'] as int
              : int.tryParse(json['confidence'].toString()) ?? 0,
      detectionDescription: json['detectionDescription'] as String,
      diseaseCauses:
          (json['diseaseCauses'] as List<dynamic>)
              .map((e) => e.toString())
              .toList(),
      diseaseSymptoms:
          (json['diseaseSymptoms'] as List<dynamic>)
              .map((e) => e.toString())
              .toList(),
      diseaseTreatment:
          (json['diseaseTreatment'] as List<dynamic>)
              .map((e) => e.toString())
              .toList(),
      source: json['source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inferenceId': inferenceId,
      'diseaseClass': diseaseClass,
      'confidence': confidence,
      'detectionDescription': detectionDescription,
      'diseaseCauses': diseaseCauses,
      'diseaseSymptoms': diseaseSymptoms,
      'diseaseTreatment': diseaseTreatment,
      'source': source,
    };
  }
}
