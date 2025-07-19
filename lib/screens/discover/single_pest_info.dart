import 'package:agrinix/config/fonts/font_sizes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SinglePestInfo extends StatefulWidget {
  final Map<String, dynamic> pestData;

  const SinglePestInfo({super.key, required this.pestData});

  @override
  State<SinglePestInfo> createState() => _SinglePestInfoState();
}

class _SinglePestInfoState extends State<SinglePestInfo> {
  @override
  Widget build(BuildContext context) {
    final pest = widget.pestData;
    final images = pest['images'] as List<dynamic>?;
    final descriptions = pest['description'] as List<dynamic>?;
    final solutions = pest['solution'] as List<dynamic>?;
    final hosts = pest['host'] as List<dynamic>?;

    String? mainImageUrl;
    if (images != null && images.isNotEmpty) {
      final image = images[0];
      mainImageUrl =
          image['original_url'] as String? ??
          image['medium_url'] as String? ??
          image['small_url'] as String?;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar with collapsing toolbar
          SliverAppBar(
            expandedHeight: 400,
            floating: false,
            pinned: true,
            backgroundColor: Colors.green[800],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                pest['common_name'] ?? 'Unknown Pest',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  if (mainImageUrl != null)
                    CachedNetworkImage(
                      imageUrl: mainImageUrl,
                      fit: BoxFit.cover,
                      httpHeaders: {
                        'User-Agent':
                            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                        'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
                        'Accept-Language': 'en-US,en;q=0.9',
                      },
                      errorWidget:
                          (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.green[700]!,
                                  Colors.green[900]!,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 80,
                            ),
                          ),
                      placeholder:
                          (context, url) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.green[700]!,
                                  Colors.green[900]!,
                                ],
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.green[700]!, Colors.green[900]!],
                        ),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Scientific name overlay
                  Positioned(
                    bottom: 80,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pest['scientific_name'] != null)
                          Text(
                            pest['scientific_name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3.0,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        if (pest['family'] != null)
                          Text(
                            'Family: ${pest['family']}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2.0,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(FontSizes.marginMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Description Section
                  if (descriptions != null && descriptions.isNotEmpty) ...[
                    _buildSectionTitle('Description'),
                    const SizedBox(height: 12),
                    ...descriptions
                        .map((desc) => _buildDescriptionCard(desc))
                        ,
                    const SizedBox(height: 24),
                  ],

                  // Solutions Section
                  if (solutions != null && solutions.isNotEmpty) ...[
                    _buildSectionTitle('Solutions'),
                    const SizedBox(height: 12),
                    ...solutions
                        .map((solution) => _buildSolutionCard(solution))
                        ,
                    const SizedBox(height: 24),
                  ],

                  // Host Plants Section
                  if (hosts != null && hosts.isNotEmpty) ...[
                    _buildSectionTitle('Affected Plants'),
                    const SizedBox(height: 12),
                    _buildHostCard(hosts),
                    const SizedBox(height: 24),
                  ],

                  // Image Gallery
                  if (images != null && images.length > 1) ...[
                    _buildSectionTitle('More Images'),
                    const SizedBox(height: 12),
                    _buildImageGallery(images),
                    const SizedBox(height: 24),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.green[800],
      ),
    );
  }

  Widget _buildDescriptionCard(Map<String, dynamic> description) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description['subtitle'] != null)
              Text(
                description['subtitle'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            if (description['subtitle'] != null) const SizedBox(height: 8),
            if (description['description'] != null)
              Text(
                description['description'],
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionCard(Map<String, dynamic> solution) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (solution['subtitle'] != null)
              Row(
                children: [
                  Icon(Icons.healing, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      solution['subtitle'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            if (solution['subtitle'] != null) const SizedBox(height: 8),
            if (solution['description'] != null)
              Text(
                solution['description'],
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostCard(List<dynamic> hosts) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Affected Plants',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  hosts
                      .map(
                        (host) => Chip(
                          label: Text(host.toString()),
                          backgroundColor: Colors.orange[100],
                          labelStyle: TextStyle(color: Colors.orange[800]),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<dynamic> images) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final image = images[index];
          final imageUrl =
              image['original_url'] as String? ??
              image['medium_url'] as String? ??
              image['small_url'] as String?;

          return GestureDetector(
            onTap: () => _showImageDialog(imageUrl),
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    imageUrl != null
                        ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          httpHeaders: {
                            'User-Agent':
                                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                            'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
                            'Accept-Language': 'en-US,en;q=0.9',
                          },
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                        )
                        : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImageDialog(String? imageUrl) {
    if (imageUrl == null) return;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  httpHeaders: {
                    'User-Agent':
                        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                    'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
                    'Accept-Language': 'en-US,en;q=0.9',
                  },
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 80,
                        ),
                      ),
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
