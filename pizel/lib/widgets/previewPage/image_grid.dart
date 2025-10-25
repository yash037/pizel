import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:collection';
import '../../utils/image_node.dart';

class ImageGrid extends StatelessWidget {
  final LinkedList<ImageNode> images;
  final int crossAxisCount;
  final double spacing;

  const ImageGrid({
    super.key,
    required this.images,
    this.crossAxisCount = 3,
    this.spacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final node = images.elementAt(index);
        return ImageGridItem(file: node.file);
      },
    );
  }
}

class ImageGridItem extends StatelessWidget {
  final File file;

  const ImageGridItem({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        file,
        fit: BoxFit.cover,
      ),
    );
  }
}
