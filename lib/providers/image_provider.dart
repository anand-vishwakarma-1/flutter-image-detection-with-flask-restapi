import 'dart:convert';

import 'package:flask_test/helpers/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prediction {
  final String className;
  final int count;
  final List<double> scores;

  Prediction({
    @required this.className,
    @required this.count,
    @required this.scores,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      className: json['className'],
      count: json['count'],
      scores: json['scores'],
    );
  }
}

class ImageData with ChangeNotifier {
  final String id;
  final String imageName;
  final String imagePath;
  final bool isUploaded;
  List<Map<String, dynamic>> predictions;
  int predictionCount;
  bool isPredicted;

  ImageData({
    @required this.id,
    @required this.imageName,
    @required this.imagePath,
    @required this.isUploaded,
    this.predictionCount,
    this.predictions,
    this.isPredicted = false,
  });

  Future<void> dbEntry({bool isUpdate = false}) async {
    final data = {
      "id": id,
      "imageName": imageName,
      "imagePath": imagePath,
      "isUploaded": isUploaded ? 1 : 0,
      "isPredicted": isPredicted ? 1 : 0,
      "predictionCount": predictionCount,
      "predictions": json.encode(predictions),
    };
    if (isUpdate) {
      DBHelper.update('images', data);
    } else {
      DBHelper.insert('images', data);
    }
  }
}

class ImageDataProvider with ChangeNotifier {
  List<ImageData> _items = [];
  bool predicted = true;
  bool notPredicted = true;
  bool reverse = false;
  bool predictionSort = false;

  List<ImageData> get items {
    List<ImageData> newItems;
    if (predicted && notPredicted) {
      newItems = [..._items];
    } else if (predicted) {
      newItems = _items.where((element) => element.isPredicted).toList();
    } else {
      newItems = _items.where((element) => !element.isPredicted).toList();
    }
    if (!reverse) {
      newItems = newItems.reversed.toList();
    }
    if (predictionSort) {
      newItems.sort((a, b) => b.predictionCount.compareTo(a.predictionCount));
    }
    return newItems;
  }

  Map<String, bool> get filters {
    return {
      "predicted": predicted,
      "notPredicted": notPredicted,
      "reverse": reverse,
      "predictionSort": predictionSort,
    };
  }

  Future<void> loadFilters() async {
    final prefs = await SharedPreferences.getInstance();
    predicted = prefs.getBool("predicted");
    notPredicted = prefs.getBool("notPredicted");
    reverse = prefs.getBool("reverse");
    predictionSort = prefs.getBool("predictionSort");
  }

  Future<void> storeFilters() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("predicted", predicted);
    prefs.setBool("notPredicted", notPredicted);
    prefs.setBool("reverse", reverse);
    prefs.setBool("predictionSort", predictionSort);
    prefs.setBool("filtersStored", true);
  }

  void updateFilters({bool pred, bool notPred, bool rev, bool predSort}) async {
    predicted = pred;
    notPredicted = notPred;
    reverse = rev;
    predictionSort = predSort;
    notifyListeners();
    storeFilters();
  }

  Future<void> runOnce() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("filtersStored")) {
      await storeFilters();
    }
  }

  Future<void> addImage(
    String id,
    String imageName,
    String imagePath,
    bool isUploaded,
  ) async {
    final newImage = ImageData(
      id: id,
      imageName: imageName,
      imagePath: imagePath,
      isUploaded: isUploaded,
      isPredicted: false,
      predictionCount: 0,
      predictions: [],
    );
    _items.add(newImage);
    notifyListeners();
    await newImage.dbEntry();
  }

  Future<void> fetchImages() async {
    final dataList = await DBHelper.getData('images');
    _items = dataList
        .map(
          (e) => ImageData(
            id: e['id'],
            imageName: e['imageName'],
            imagePath: e['imagePath'],
            isUploaded: e['isUploaded'] == 1 ? true : false,
            isPredicted: e['isPredicted'] == 1 ? true : false,
            predictionCount: e['predictionCount'],
            predictions: e['predictionCount'] > 0
                ? (json.decode(e['predictions']) as List)
                    .map(
                      (value) => value as Map<String, dynamic>,
                    )
                    .toList()
                : [],
          ),
        )
        .toList();
    notifyListeners();
  }

  Future<String> updateImage(String id, List<dynamic> data) async {
    if (data.length > 1) {
      final imageData = _items.firstWhere((element) => element.id == id);
      _items.removeWhere((element) => element.id == id);
      imageData.isPredicted = true;
      imageData.predictionCount = data[1];
      imageData.predictions = (data[0] as List)
          .map(
            (value) => value as Map<String, dynamic>,
          )
          .toList();
      _items.add(imageData);
      notifyListeners();
      await imageData.dbEntry(isUpdate: true);
      return "success";
    } else {
      return data[0];
    }
  }

  Future<void> deleteImage(String id) async {
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
    await DBHelper.delete("images", id);
  }

  ImageData findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }
}
