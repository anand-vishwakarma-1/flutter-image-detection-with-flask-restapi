import 'dart:io';

import 'package:flask_test/functions/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/image_provider.dart';
import '../providers/flask_provider.dart';
import '../functions/server_connection.dart';

class ImageDetail extends StatefulWidget {
  static const routeName = "/image-detail";
  bool _isDeleted = false;
  bool _isPredicting = false;

  @override
  _ImageDetailState createState() => _ImageDetailState();
}

class _ImageDetailState extends State<ImageDetail> {
  @override
  Widget build(BuildContext context) {
    String imageId = ModalRoute.of(context).settings.arguments as String;
    if (widget._isDeleted) {
      return Container();
    }

    final imageData = Provider.of<ImageDataProvider>(
      context,
      listen: false,
    ).findById(imageId);

    void _predict(BuildContext ctx) async {
      String result;
      if (Provider.of<FLaskProvider>(context, listen: false).connection) {
        setState(() {
          widget._isPredicting = true;
        });
        result = await Provider.of<ImageDataProvider>(context, listen: false)
            .updateImage(
          imageId,
          await Provider.of<FLaskProvider>(context, listen: false)
              .getPredictions(
            imageData.imageName,
            imageData.imagePath,
          ),
        );
      } else {
        showSnackBar(ctx, 'Not Connected to Server');
      }
      setState(() {
        widget._isPredicting = false;
      });
    }

    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('dd-MM-yy hh:mm').format(DateTime.parse(imageData.id)),
        ),
        actions: <Widget>[
          Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                widget._isDeleted = true;
                Navigator.pop(context, imageId);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<FLaskProvider>(
        child: Container(),
        builder: (ctx, flaskHelper, ch) => flaskHelper.connection
            ? ch
            : Builder(
                builder: (context) => FlatButton(
                  onPressed: () => connectToServer(context),
                  child: Text("Connect to Server"),
                  color: Theme.of(context).accentColor,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: widget._isPredicting
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    width: mediaQuery.size.width,
                    height: mediaQuery.size.width - 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.black87,
                    ),
                    child: Hero(
                      tag: imageData.id,
                      child: Image.file(
                        File(imageData.imagePath),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (!imageData.isPredicted)
                    Builder(
                      builder: (ctx) => FlatButton.icon(
                        onPressed: () => _predict(ctx),
                        icon: Icon(Icons.call_to_action),
                        label: Text('Predict Now'),
                        color: Theme.of(context).accentColor,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Predictions",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (!imageData.isPredicted) Text("Not Predicted Yet"),
                  if (imageData.isPredicted)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.only(
                        bottom: 10,
                        left: 30,
                        right: 30,
                      ),
                      height: (mediaQuery.size.height - mediaQuery.size.width)
                              .abs() -
                          60 -
                          AppBar().preferredSize.height,
                      child: imageData.predictionCount > 0
                          ? ListView.builder(
                              itemCount: imageData.predictions.length,
                              itemBuilder: (ctx, i) => ListTile(
                                leading: CircleAvatar(
                                  child: Text(imageData.predictions[i]['count']
                                      .toString()),
                                ),
                                title:
                                    Text(imageData.predictions[i]['className']),
                                subtitle: Text(
                                    "Scores: ${imageData.predictions[i]['scores']}"),
                              ),
                            )
                          : Center(
                              child: Text("No Predctions in this Image"),
                            ),
                    ),
                ],
              ),
            ),
    );
  }
}
