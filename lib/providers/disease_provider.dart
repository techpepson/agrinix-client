import 'package:agrinix/models/disease_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiseaseProvider extends StateNotifier<DiseaseModel> {
  DiseaseProvider()
    : super(
        DiseaseModel(
          inferenceId: '',
          confidence: 0,
          detectionDescription: '',
          diseaseCauses: [],
          diseaseClass: '',
          diseaseSymptoms: [],
          diseaseTreatment: [],
          source: '',
        ),
      );

  void updateInferenceId(String value) {
    state = state.copyWith(inferenceId: value);
  }

  void updateConfidence(int value) {
    state = state.copyWith(confidence: value);
  }

  void updateDetectionDescription(String value) {
    state = state.copyWith(detectionDescription: value);
  }

  void updateDiseaseCauses(List<String> value) {
    state = state.copyWith(diseaseCauses: value);
  }

  void updateDiseaseClass(String value) {
    state = state.copyWith(diseaseClass: value);
  }

  void updateDiseaseSymptoms(List<String> value) {
    state = state.copyWith(diseaseSymptoms: value);
  }

  void updateDiseaseTreatment(List<String> value) {
    state = state.copyWith(diseaseTreatment: value);
  }

  void updateSource(String value) {
    state = state.copyWith(source: value);
  }

  void updateAll(DiseaseModel model) {
    state = model;
  }
}

final diseaseProvider = StateNotifierProvider<DiseaseProvider, DiseaseModel>((
  ref,
) {
  return DiseaseProvider();
});
