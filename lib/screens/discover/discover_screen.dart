import "package:agrinix/config/fonts/font_sizes.dart";
import "package:agrinix/core/services/crop_disease_list.dart";
import "package:agrinix/data/discover_page_data.dart";
import "package:agrinix/providers/fetch_crop_pest_provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:glassmorphism_ui/glassmorphism_ui.dart";
import 'dart:developer' as dev;

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  List<Map<String, dynamic>> pestList = [];
  bool isPestFetchFailed = false;
  bool isLoadingPestFetch = false;
  final DiscoverPageData _discoverPageData = DiscoverPageData();

  @override
  void initState() {
    super.initState();
    // Listen for changes to the provider and update state accordingly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen(fetchPestDiseaseProvider, (previous, next) {
        next.when(
          data: (data) {
            setState(() {
              pestList = data;
              isPestFetchFailed = false;
              isLoadingPestFetch = false;
            });
          },
          error: (error, stack) {
            setState(() {
              isPestFetchFailed = true;
              isLoadingPestFetch = false;
            });
          },
          loading: () {
            setState(() {
              isLoadingPestFetch = true;
              isPestFetchFailed = false;
            });
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/capture-crop.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(color: Colors.black.withAlpha(170)),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 10,
                      child: _buildWeatherOverlay(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: FontSizes.marginMd,
                vertical: FontSizes.marginMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Plant Conditions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildCropList(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherOverlay(BuildContext context) {
    String weatherDescription = _discoverPageData.weatherData['description'];
    IconData iconData = Icons.sunny;

    switch (weatherDescription) {
      case "sunny":
        iconData = Icons.sunny;
        break;
      case "rainy":
        iconData = Icons.water;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Date and Temperature
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_discoverPageData.weatherData["currentDay"]}, ${_discoverPageData.weatherData["currentMonth"]} ${_discoverPageData.weatherData["currentYear"]}",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${_discoverPageData.weatherData['temperature']}°C",
                        style: Theme.of(
                          context,
                        ).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Right: Weather Description
              Row(
                children: [
                  Text(
                    weatherDescription,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Icon(iconData, size: 36, color: Colors.orange[700]),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildWeatherMetric(),
        ],
      ),
    );
  }

  Widget _buildWeatherMetric() {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(width: 10);
        },
        itemCount: _discoverPageData.weatherData['weatherData'].length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = _discoverPageData.weatherData['weatherData'][index];

          IconData iconData;
          switch (item['name']) {
            case 'Humidity':
              iconData = Icons.water_drop;
              break;
            case 'WindSpeed':
              iconData = Icons.air;
              break;
            case 'UV Index':
              iconData = Icons.wb_sunny;
              break;
            case 'Air Quality':
              iconData = Icons.cloud;
              break;
            default:
              iconData = Icons.thermostat;
          }
          return GlassContainer(
            blur: 3,
            opacity: 0.3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(iconData, color: Colors.white, size: 24),
                      SizedBox(width: 15),
                      Text(
                        item['name'],
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${item['value'].toString()} ${item["unit"]}",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCropList(BuildContext context) {
    if (isLoadingPestFetch) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (isPestFetchFailed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'Failed to load pest data.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }
    if (pestList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No pest data found.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }
    // Show a scrollable list of pest cards
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pestList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final pest = pestList[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pest['commonName'] ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pest['scientificName'] ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    pest['host'] ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCropCard(BuildContext context, Map<String, dynamic> crop) {
    return GlassContainer();
  }
}
