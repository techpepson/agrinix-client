import "package:agrinix/config/fonts/font_sizes.dart";
import "package:agrinix/config/theme/app_theme.dart";
import "package:agrinix/core/services/app_services.dart";
import "package:agrinix/core/services/weather_services.dart";
import "package:agrinix/data/discover_page_data.dart";
import "package:agrinix/providers/fetch_crop_pest_provider.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:glassmorphism_ui/glassmorphism_ui.dart";
import "package:geolocator/geolocator.dart";
import "package:go_router/go_router.dart";

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  List<Map<String, dynamic>> pestList = [];
  bool isPestFetchFailed = false;
  bool isLoadingPestFetch = false;
  Map<String, dynamic> weatherData = {};
  bool isLoadingWeather = false;
  Position? currentPosition;
  String locationStatus = 'Getting location...';

  AppServices appServices = AppServices();
  WeatherServices weatherServices = WeatherServices();

  Future<void> getLocationAndWeather() async {
    try {
      setState(() {
        locationStatus = 'Getting location...';
        isLoadingWeather = true;
      });

      Position position = await appServices.determineUserLocation();

      setState(() {
        currentPosition = position;
        locationStatus = 'Location obtained!';
      });

      // Fetch weather data using the position
      final weather = await weatherServices.getWeatherForLocation(position);

      setState(() {
        weatherData = weather;
        isLoadingWeather = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: appTheme.colorScheme.error,
          content: Text(
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
            "An error occurred getting location data. Please turn on your location services.",
          ),
        ),
      );
      setState(() {
        locationStatus = 'Location error: $e';
        isLoadingWeather = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize with default weather data
    weatherData = {
      'currentDay': 'Loading...',
      'currentMonth': '',
      'currentYear': DateTime.now().year,
      'description': 'sunny',
      'temperature': 0,
      'weatherData': [
        {'name': 'Humidity', 'value': 0, 'unit': '%'},
        {'name': 'Wind Speed', 'value': 0, 'unit': 'm/s'},
        {'name': 'UV Index', 'value': '0', 'unit': ''},
        {'name': 'Pressure', 'value': 0, 'unit': 'hPa'},
      ],
    };

    // Call getLocationAndWeather only once when widget initializes
    getLocationAndWeather();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.read(fetchPestDiseaseProvider);
    provider.when(
      data: (data) {
        pestList = data;
      },
      error: (error, trace) {},
      loading: () {},
    );

    // getLocationAndWeather() is now called in initState to avoid multiple calls

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh both weather and pest data
          await getLocationAndWeather();
          // You can also refresh pest data here if needed
        },
        child: CustomScrollView(
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
                      'Explore Plant Conditions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            if (isLoadingPestFetch)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (isPestFetchFailed)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Failed to load pest data.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              )
            else if (pestList.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No pest data found.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: FontSizes.marginMd,
                      vertical: 8,
                    ),
                    child: _buildCropCard(context, pestList[index]),
                  );
                }, childCount: pestList.length),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherOverlay(BuildContext context) {
    // Use weatherData if available, otherwise show loading
    if (weatherData.isEmpty || isLoadingWeather) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    String weatherDescription = weatherData['description'] ?? 'sunny';
    IconData iconData = Icons.sunny;

    switch (weatherDescription.toLowerCase()) {
      case "sunny":
      case "clear":
        iconData = Icons.sunny;
        break;
      case "rainy":
      case "rain":
        iconData = Icons.water;
        break;
      case "cloudy":
      case "clouds":
      case "overcast":
        iconData = Icons.cloud;
        break;
      case "snow":
        iconData = Icons.ac_unit;
        break;
      case "thunderstorm":
        iconData = Icons.thunderstorm;
        break;
      case "fog":
      case "mist":
        iconData = Icons.foggy;
        break;
      default:
        iconData = Icons.cloud; // Default to cloud for unknown conditions
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
                    "${weatherData['currentDay']}, ${weatherData['currentMonth']} ${weatherData['currentYear']}",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${weatherData['temperature']}°C",
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
        itemCount: weatherData['weatherData']?.length ?? 0,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = weatherData['weatherData'][index];

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

  Widget _buildCropCard(BuildContext context, Map<String, dynamic> pest) {
    final images = pest['images'] as List<dynamic>?;
    String? imageUrl;

    if (images != null && images.isNotEmpty) {
      // Try to get a smaller image URL first (often more accessible)
      final image = images[0];
      imageUrl =
          image['thumbnail'] as String? ??
          image['small_url'] as String? ??
          image['medium_url'] as String? ??
          image['original_url'] as String?;
    }

    return GestureDetector(
      onTap: () {
        // Navigate to single pest info page
        context.push('/discover/pest/${pest['id']}', extra: pest);
      },
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(70),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background Image
              if (imageUrl != null)
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  httpHeaders: {
                    'User-Agent':
                        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                    'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
                    'Accept-Language': 'en-US,en;q=0.9',
                    'Cache-Control': 'cache',
                  },
                  errorWidget:
                      (context, url, error) => Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.grey[300]!, Colors.grey[400]!],
                          ),
                        ),
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                  placeholder:
                      (context, url) => Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.grey[200]!, Colors.grey[300]!],
                          ),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                )
              else
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey[300]!, Colors.grey[400]!],
                    ),
                  ),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              // Gradient overlay for better text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withAlpha(56)],
                  ),
                ),
              ),
              // Pest name overlay
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pest['common_name'] ?? 'Unknown Pest',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (pest['scientific_name'] != null)
                      Text(
                        pest['scientific_name'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
