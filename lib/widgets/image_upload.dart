import 'dart:io';

import 'package:flask_test/providers/image_provider.dart';
import 'package:flask_test/screens/image_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

import '../widgets/custom_button.dart';
import '../providers/flask_provider.dart';

class ImageUpload extends StatefulWidget {
  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  double _uploadProgress;
  bool _isUploading = false;
  bool _isUploaded = false;
  bool _isPredicting = false;
  File _pickedImage;
  String imageId;
  String imageName;
  String imagePath;

  void _updateProgress(double progress) {
    setState(() {
      _isUploading = true;
      _uploadProgress = progress;
    });
  }

  Widget _showImagePreview() {
    return _isUploading
        ? SizedBox(
            height: 100.0,
            child: Stack(
              children: <Widget>[
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    child: new CircularProgressIndicator(
                      strokeWidth: 10,
                      value: _uploadProgress,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    (_uploadProgress * 100).floor().toString(),
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          )
        : _pickedImage != null
            ? Image.file(
                _pickedImage,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/images/upload_image.png',
                fit: BoxFit.cover,
              );
  }

  void _predict() async {
    setState(() {
      _isPredicting = true;
    });
    final result = await Provider.of<ImageDataProvider>(context, listen: false)
        .updateImage(
      imageId,
      await Provider.of<FLaskProvider>(context, listen: false).getPredictions(
        imageName,
        imagePath,
      ),
    );
    if (result == "success") {
      Navigator.pop(context, 'Predicted Successfully');
    } else if (result == "failed") {
      Navigator.pop(context, 'There was some Error');
    }
    Navigator.of(context).pushNamed(ImageDetail.routeName, arguments: imageId);
  }

  void _pickImage(ImageSource imageSource) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: imageSource);
    setState(() {
      _pickedImage = File(pickedImage.path);
    });
    final flask = Provider.of<FLaskProvider>(context, listen: false);
    final status = await flask.uploadImage(_pickedImage, _updateProgress);
    setState(() {
      _isUploading = false;
      _isUploaded = true;
    });
    if (status == "success") {
      // showSnackBar(context, 'Image Uploaded Successfully');
      final appDir = await syspaths.getApplicationDocumentsDirectory();
      imageName = path.basename(pickedImage.path);
      imagePath =
          (await File(pickedImage.path).copy("${appDir.path}/$imageName")).path;
      imageId = DateTime.now().toIso8601String();
      Provider.of<ImageDataProvider>(context, listen: false).addImage(
        imageId,
        imageName,
        imagePath,
        true,
      );
    } else {
      _pickedImage = null;
      Navigator.pop(context, 'Image not Uploaded');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isPredicting
        ? Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            child: Card(
              elevation: 10,
              child: Container(
                margin: EdgeInsets.only(
                  top: 15,
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 15,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 300,
                      width: 300,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: Colors.blueGrey,
                        ),
                      ),
                      child: _showImagePreview(),
                    ),
                    if (!_isUploading)
                      CustomButton(
                          _isUploaded, _isUploaded ? _predict : _pickImage),
                  ],
                ),
              ),
            ),
          );
  }
}
