import 'dart:io';

import 'package:flask_test/functions/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/image_provider.dart';
import '../screens/image_detail_screen.dart';

class ImageItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final imageData = Provider.of<ImageData>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .pushNamed(ImageDetail.routeName, arguments: imageData.id)
                .then((value) async {
              if (value != null) {}
            });
          },
          child: Hero(
            tag: imageData.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/image_placeholder.jpg'),
              image: FileImage(
                File(imageData.imagePath),
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<ImageData>(
            builder: (ctx, image, _) => image.isPredicted
                ? Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.check_circle_outline,
                    color: Colors.red,
                  ),
          ),
          title: Text(
            DateFormat('dd-MM hh:mm').format(DateTime.parse(imageData.id)),
            textAlign: TextAlign.center,
            textScaleFactor: 1.2,
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            color: Colors.red,
            alignment: Alignment.centerRight,
            onPressed: () async {
              await Provider.of<ImageDataProvider>(context, listen: false)
                  .deleteImage(imageData.id);
              showSnackBar(
                  context, "Image (${imageData.id}) Deleted Successfully");
            },
          ),

        ),
      ),
    );
  }
}
