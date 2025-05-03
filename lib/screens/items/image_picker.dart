import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomImagePicker extends StatelessWidget {
  final List<XFile> imageFiles;
  final List<String> imageUrls;
  final Function(XFile) onFileSelected;
  final Function(int) onImageRemoved;

  const CustomImagePicker({
    super.key,
    this.imageFiles = const [],
    this.imageUrls = const [],
    required this.onFileSelected,
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
        if (imageFiles.isNotEmpty || imageUrls.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: imageFiles.length + imageUrls.length,
            itemBuilder: (context, index) {
              if (index < imageFiles.length) {
                return _XFilePreview(
                  imageFile: imageFiles[index],
                  onRemove: () => onImageRemoved(index),
                );
              } else {
                final imageIndex = index - imageFiles.length;
                return _UrlPreview(
                  imageUrl: imageUrls[imageIndex],
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
                    onFileSelected(image);
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
                    onFileSelected(image);
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

class _XFilePreview extends StatelessWidget {
  final XFile imageFile;
  final VoidCallback onRemove;

  const _XFilePreview({
    required this.imageFile,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<String>(
          future: imageFile.readAsBytes().then((bytes) => 'data:image;base64,${base64Encode(bytes)}'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(snapshot.data!.split(',').last),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            } else {
              return Container(
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              );
            }
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
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.broken_image,
                color: Colors.red,
              ),
            ),
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