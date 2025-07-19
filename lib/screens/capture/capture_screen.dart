import 'dart:convert';
import 'dart:io';
import 'package:agrinix/services/crop_capture_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrinix/screens/library/single_crop_details.dart';
import 'dart:developer' as dev;

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _capturedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  String errorText = '';

  final CropCaptureService cropCaptureService = CropCaptureService();

  Future<void> _captureImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error capturing image: $e');
      _showErrorSnackBar('Failed to capture image. Please try again.');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorSnackBar(
        'Failed to pick image from gallery. Please try again.',
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _analyzeImage() async {
    if (_capturedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      errorText = '';
    });

    try {
      dev.log(_capturedImage.toString());
      final request = await cropCaptureService.uploadCropImage(
        _capturedImage,
        ref,
      );

      final results =
          request.data is String ? jsonDecode(request.data) : request.data;

      if (request.statusCode == 201 || request.statusCode == 200) {
        // If the response only contains a message and no prediction, show the message
        if (results is Map &&
            results.containsKey('message') &&
            results.length == 1) {
          setState(() {
            _isAnalyzing = false;
            errorText = results['message'] ?? 'No disease prediction found.';
            _analysisResult = null;
          });
          return;
        }
        // Parse the server response for relevant fields and map to SingleCropDetails expectations
        final diseaseInfo = results['diseaseInfo'] ?? {};
        final prediction =
            results['response']?['outputs']?[0]?['model_prediction_output'] ??
            {};
        final confidence = prediction['confidence'] ?? 0.0;
        final cropName = results['cropName'] ?? '';
        final diseaseClass = results['class'] ?? '';
        final description = diseaseInfo['description'] ?? '';
        final causes = (diseaseInfo['causes'] as List?)?.cast<String>() ?? [];
        final symptoms =
            (diseaseInfo['symptoms'] as List?)?.cast<String>() ?? [];
        final prevention =
            (diseaseInfo['prevention'] as List?)?.cast<String>() ?? [];
        final treatment =
            (diseaseInfo['treatment'] as List?)?.cast<String>() ?? [];
        final source = diseaseInfo['source'] ?? '';
        final imageUrl = results['imageUrl'] ?? '';

        setState(() {
          _analysisResult = {
            'name': cropName,
            'diseaseClass': diseaseClass,
            'predictionAccuracy': confidence, // for _buildAccuracyCard
            'diseaseDescription': description,
            'diseaseCauses': causes,
            'diseaseSymptoms': symptoms,
            'diseasePrevention': prevention,
            'diseaseTreatment': treatment,
            'source': source,
            'imageUrl': imageUrl,
          };
          _isAnalyzing = false;
          errorText = '';
        });
        dev.log(name: "Server response", results.toString());
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        errorText = 'Failed to analyze image. Please try again.';
      });
      // print('Error analyzing image: $e');
      _showErrorSnackBar('Failed to analyze image. Please try again.');
    }
  }

  void _resetCapture() {
    setState(() {
      _capturedImage = null;
      _analysisResult = null;
      errorText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Crop'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: _capturedImage == null ? _buildCaptureView() : _buildResultView(),
    );
  }

  Widget _buildCaptureView() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (errorText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                errorText,
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          // Header section
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[300]!, width: 2),
                color: Colors.grey[100],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 80, color: Colors.green[600]),
                  const SizedBox(height: 16),
                  Text(
                    'Capture Your Crop',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take a photo or select from gallery',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'How to get the best results:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInstructionItem(
                  icon: Icons.lightbulb,
                  text: 'Ensure good lighting',
                ),
                _buildInstructionItem(
                  icon: Icons.block,
                  text: 'Non crop images will not be processed',
                ),
                _buildInstructionItem(
                  icon: Icons.center_focus_strong,
                  text: 'Focus on the affected area',
                ),
                _buildInstructionItem(
                  icon: Icons.crop_square,
                  text: 'Keep the crop centered in frame',
                ),
                _buildInstructionItem(
                  icon: Icons.photo_camera,
                  text: 'Avoid shadows and reflections',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _captureImageFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Column(
      children: [
        // Image preview
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green[300]!, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                _capturedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        ),

        // Analysis results or analyze button
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(16),
            child:
                _analysisResult == null
                    ? _buildAnalyzeSection()
                    : _buildAnalysisResults(),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.analytics, size: 64, color: Colors.green[600]),
        const SizedBox(height: 16),
        Text(
          'Ready to analyze?',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the button below to analyze your crop for diseases',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _isAnalyzing ? null : _analyzeImage,
          icon:
              _isAnalyzing
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.search),
          label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Crop'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: _resetCapture,
          icon: const Icon(Icons.refresh),
          label: const Text('Take New Photo'),
        ),
      ],
    );
  }

  Widget _buildAnalysisResults() {
    final result = _analysisResult!;
    final accuracy = (result['predictionAccuracy'] * 100).toStringAsFixed(1);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Complete',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Crop: ${result['name']}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Disease info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          result['diseaseClass'] ?? 'Unknown Disease',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$accuracy% Confidence',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result['diseaseDescription'] ?? 'No description available',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  if ((result['diseaseCauses'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Causes:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...List<Widget>.from(
                          (result['diseaseCauses'] as List).map(
                            (c) => Text('- $c'),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  if ((result['diseaseSymptoms'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Symptoms:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...List<Widget>.from(
                          (result['diseaseSymptoms'] as List).map(
                            (s) => Text('- $s'),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  if ((result['diseasePrevention'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prevention:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...List<Widget>.from(
                          (result['diseasePrevention'] as List).map(
                            (p) => Text('- $p'),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  if ((result['diseaseTreatment'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Treatment:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...List<Widget>.from(
                          (result['diseaseTreatment'] as List).map(
                            (t) => Text('- $t'),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  if ((result['source'] as String).isNotEmpty)
                    Text(
                      'Source: ${result['source']}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SingleCropDetails(cropData: result),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('See Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetCapture,
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Photo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
