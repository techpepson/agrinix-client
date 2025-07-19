import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrinix/services/messages_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrinix/providers/message_provider.dart';

class CreateMessage extends ConsumerStatefulWidget {
  const CreateMessage({super.key});

  @override
  ConsumerState<CreateMessage> createState() => _CreateMessageState();
}

class _CreateMessageState extends ConsumerState<CreateMessage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final MessagesService messagesService = MessagesService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
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

  void _removeImage() {
    setState(() {
      _capturedImage = null;
    });
  }

  Future<void> _submitMessage() async {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a title for your message');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a description for your message');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Update the messageProvider state with the current form values
    ref
        .read(messageProvider.notifier)
        .updateMessageTitle(_titleController.text.trim());
    ref
        .read(messageProvider.notifier)
        .updateMessageBody(_descriptionController.text.trim());
    // You can add messageLink if you have a field for it

    try {
      await messagesService.sendMessage(ref, _capturedImage);
      setState(() {
        _isLoading = false;
      });
      _showSuccessSnackBar('Message posted successfully!');
      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _capturedImage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Ask Community",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(),
                    SizedBox(height: 24),
                    _buildFormSection(),
                  ],
                ),
              ),
            ),
            _buildSubmitSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Add Image (Optional)",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        if (_capturedImage != null) ...[
          _buildImageDisplay(),
          SizedBox(height: 16),
        ],
        _buildImageButton(),
      ],
    );
  }

  Widget _buildImageButton() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: _pickImageFromGallery,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 8),
            Text(
              'Add Image',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Tap to select from gallery',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageDisplay() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _capturedImage!,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _removeImage,
                icon: Icon(Icons.close, color: Colors.white, size: 20),
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Message Details",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 20),
        _buildTextField(
          onChanged: (value) {
            setState(() {
              ref.read(messageProvider.notifier).updateMessageTitle(value);
            });
          },
          controller: _titleController,
          hintText: "Enter a clear, descriptive title",
          maxLength: 100,
          maxLines: 2,
          label: "Title",
          icon: Icons.title,
        ),
        SizedBox(height: 20),
        _buildTextField(
          onChanged: (value) {
            setState(() {
              ref.read(messageProvider.notifier).updateMessageBody(value);
            });
          },
          controller: _descriptionController,
          hintText:
              "Provide detailed description of your question or concern. Be specific and polite.",
          maxLength: 2000,
          maxLines: 8,
          label: "Description",
          icon: Icons.description,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required ValueChanged<String> onChanged,
    required TextEditingController controller,
    required String hintText,
    required int maxLength,
    required int maxLines,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            onChanged: onChanged,
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(170),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: EdgeInsets.all(16),
              counterStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Posting...",
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Post Message",
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
