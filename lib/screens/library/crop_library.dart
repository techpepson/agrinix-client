import 'package:agrinix/data/library_data.dart';
import 'package:agrinix/screens/library/single_crop_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CropLibrary extends StatefulWidget {
  const CropLibrary({super.key});

  @override
  State<CropLibrary> createState() => _CropLibraryState();
}

class _CropLibraryState extends State<CropLibrary> {
  LibraryData libraryData = LibraryData();

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
          children: [_buildCropItemList(), _buildDiseaseItemList()],
        ),
      ),
    );
  }

  Widget _buildCropItemList() {
    if (libraryData.cropList.isEmpty) {
      return const Center(child: Text("Crop library empty at the moment"));
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: libraryData.cropList.length,
        itemBuilder: (context, index) {
          final item = libraryData.cropList[index];
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
                      child: CachedNetworkImage(
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
    if (libraryData.cropList.isEmpty) {
      return const Center(child: Text("Disease library empty at the moment"));
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: libraryData.cropList.length,
        itemBuilder: (context, index) {
          final item = libraryData.cropList[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SingleCropDetails(cropData: item);
                  },
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bug_report, color: Colors.red[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['diseaseClass'] ?? 'Unknown Disease',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(item['predictionAccuracy'] * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['diseaseDescription'] ?? 'No description available',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Affects: ${item['name'] ?? 'Unknown Crop'}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
