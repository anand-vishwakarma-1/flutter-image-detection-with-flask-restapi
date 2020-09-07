import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomButton extends StatelessWidget {
  final bool _isUploaded;
  final Function _actionFn;

  CustomButton(this._isUploaded, this._actionFn);

  @override
  Widget build(BuildContext context) {
    return _isUploaded
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton.icon(
                onPressed: _actionFn,
                icon: Icon(Icons.call_to_action),
                label: Text('Predict Now'),
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              FlatButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.watch_later),
                label: Text('Predict Later'),
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton.icon(
                onPressed: () => _actionFn(ImageSource.camera),
                icon: Icon(Icons.photo_camera),
                label: Text('Camera'),
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              FlatButton.icon(
                onPressed: () => _actionFn(ImageSource.gallery),
                icon: Icon(Icons.photo_library),
                label: Text('Gallery'),
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          );
  }
}
