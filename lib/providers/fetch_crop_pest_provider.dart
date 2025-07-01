import 'package:agrinix/core/services/crop_disease_list.dart';
import 'package:agrinix/models/crop_pest_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FetchCropPestProvider extends StateNotifier<CropPestModel> {
  FetchCropPestProvider()
    : super(
        CropPestModel(
          id: 1,
          commonName: "",
          description: [],
          host: '',
          images: [],
          scientificName: '',
          solution: [],
        ),
      );

  void updateId(dynamic value) {
    state = state.copyWith(id: value);
  }

  void updateCommonName(String value) {
    state = state.copyWith(commonName: value);
  }

  void updateDescription(List<Map<String, dynamic>> value) {
    state = state.copyWith(description: value);
  }

  void updateSolution(List<Map<String, dynamic>> value) {
    state = state.copyWith(solution: value);
  }

  void updateImages(List<Map<String, dynamic>> value) {
    state = state.copyWith(images: value);
  }

  void updateHost(String value) {
    state = state.copyWith(host: value);
  }

  void updateScientificName(String value) {
    state = state.copyWith(scientificName: value);
  }

  //call the disease fetch method
  CropDiseases diseases = CropDiseases();

  Future<List<Map<String, dynamic>>> diseasePestFetch() async {
    final result = diseases.fetchCropDiseases();
    return result;
  }
}

final fetchPestDiseaseProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final notifier = FetchCropPestProvider();
  final data = notifier.diseasePestFetch();
  return data;
});
