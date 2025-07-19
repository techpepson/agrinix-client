import 'package:agrinix/screens/library/single_crop_details.dart';
import 'package:agrinix/services/crop_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CropLibrary extends StatefulWidget {
  const CropLibrary({super.key});

  @override
  State<CropLibrary> createState() => _CropLibraryState();
}

class _CropLibraryState extends State<CropLibrary> {
  // LibraryData libraryData = LibraryData();
  CropList cropListService = CropList();
  List<Map<String, dynamic>> farmerCrops = [];
  bool isLoading = true;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    fetchFarmerCrops();
  }

  Future<void> fetchFarmerCrops() async {
    setState(() {
      isLoading = true;
      errorText = '';
    });
    try {
      final response = await cropListService.fetchFarmerCrops();
      final data = response.data;
      final List<dynamic> cropsData = data['data']?[0]?['crops'] ?? [];
      farmerCrops =
          cropsData.map<Map<String, dynamic>>((crop) {
            final infection = crop['infections'] ?? {};
            // Extract the first image URL from diseaseImages if available
            String imageUrl = '';
            if (infection['diseaseImages'] is List &&
                infection['diseaseImages'].isNotEmpty) {
              final firstImage = infection['diseaseImages'][0];
              if (firstImage['imageUrl'] is List &&
                  firstImage['imageUrl'].isNotEmpty) {
                imageUrl = firstImage['imageUrl'][0];
              }
            }
            return {
              'name': crop['name'] ?? '',
              'diseaseClass': infection['diseaseClass'] ?? '',
              'predictionAccuracy': infection['accuracy'] ?? 0.0,
              'diseaseDescription': infection['diseaseDescription'] ?? '',
              'diseaseCauses': infection['diseaseCauses'] ?? [],
              'diseaseSymptoms': infection['diseaseSymptoms'] ?? [],
              'diseasePrevention': infection['diseasePrevention'] ?? [],
              'diseaseTreatment': [],
              'source': '',
              'imageUrl': imageUrl,
            };
          }).toList();
      setState(() {
        isLoading = false;
        errorText = '';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorText = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to fetch crops. Please try again.'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Library"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.agriculture), text: "Crops"),
              Tab(icon: Icon(Icons.bug_report), text: "Diseases"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await fetchFarmerCrops();
              },
              child: _buildCropItemList(),
            ),
            RefreshIndicator(
              onRefresh: () async {
                await fetchFarmerCrops();
              },
              child: _buildDiseaseItemList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropItemList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorText.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              'Failed to fetch crops.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorText,
              style: TextStyle(color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: fetchFarmerCrops,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    if (farmerCrops.isEmpty) {
      return const Center(child: Text("Crop library empty at the moment"));
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: farmerCrops.length,
        itemBuilder: (context, index) {
          final item = farmerCrops[index];
          final imageUrl =
              item['imageUrl'] is List
                  ? (item['imageUrl'] as List).first
                  : item['imageUrl'];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SingleCropDetails(cropData: item),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child:
                          imageUrl != null && imageUrl != ''
                              ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                        ),
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                              )
                              : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                    ),
                    const SizedBox(width: 16),
                    // Crop info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'Unknown Crop',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Disease: ${item['diseaseClass'] ?? 'Unknown'}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Accuracy: ${(item['predictionAccuracy'] * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.blue[600]),
                          ),
                        ],
                      ),
                    ),
                    // Arrow
                    Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildDiseaseItemList() {
    // For now, just reuse the crop list for demonstration
    return _buildCropItemList();
  }
}
