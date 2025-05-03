import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class CustomImagePicker extends StatelessWidget {
  final List<XFile> imageFiles;
  final List<String> images;
  final Function(XFile)? onFileSelected;
  final Function(String)? onImageSelected;
  final Function(int) onImageRemoved;

  const CustomImagePicker({
    super.key,
    this.imageFiles = const [],
    this.images = const [],
    this.onFileSelected,
    this.onImageSelected,
    required this.onImageRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Images*',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add at least one clear photo of the item',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        if (imageFiles.isNotEmpty || images.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: imageFiles.length + images.length,
            itemBuilder: (context, index) {
              if (index < imageFiles.length) {
                return _FilePreview(
                  imageFile: imageFiles[index],
                  onRemove: () => onImageRemoved(index),
                );
              } else {
                final imageIndex = index - imageFiles.length;
                return _UrlPreview(
                  imageUrl: images[imageIndex],
                  onRemove: () => onImageRemoved(index),
                );
              }
            },
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1000,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    if (onFileSelected != null) {
                      onFileSelected!(image);
                    } else if (onImageSelected != null) {
                      // Convert to URL or handle differently if needed
                      // This is a placeholder for demonstration
                      onImageSelected!('file://${image.path}');
                    }
                  }
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1000,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    if (onFileSelected != null) {
                      onFileSelected!(image);
                    } else if (onImageSelected != null) {
                      // Convert to URL or handle differently if needed
                      // This is a placeholder for demonstration
                      onImageSelected!('file://${image.path}');
                    }
                  }
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilePreview extends StatelessWidget {
  final XFile imageFile;
  final VoidCallback onRemove;

  const _FilePreview({
    required this.imageFile,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<Uint8List>(
          future: imageFile.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UrlPreview extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onRemove;

  const _UrlPreview({
    required this.imageUrl,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.broken_image,
                  color: Colors.red,
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}