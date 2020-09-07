import 'package:flask_test/widgets/image_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flask_test/providers/image_provider.dart';

class ImageGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ImageDataProvider>(
      child: Center(
        child: const Text('No Images yet.'),
      ),
      builder: (ctx, imageData, ch) => imageData.items.length <= 0
          ? ch
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: imageData.items.length,
              itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                value: imageData.items[i],
                child: ImageItem(),
              ),
            ),
    );
  }
}
