import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class FLaskProvider with ChangeNotifier {
  bool _isConnected = false;
  String _routeUrl = "";
  bool _isInitialized = false;

  bool get isIntialized {
    return _isInitialized;
  }

  bool get connection {
    return _isConnected;
  }

  String get routeUrl {
    return _routeUrl;
  }

  void toggleInitialized() {
    _isInitialized = true;
  }

  Future<String> establishConnection(String url) async {
    try {
      _routeUrl = url;
      final response = await http.get(_routeUrl + '/');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _isConnected = true;
        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('routeUrl', _routeUrl);
        return responseData['status'];
      } else {
        _routeUrl = "";
        return "failed";
      }
    } catch (e) {
      return "";
    }
  }

  Future<bool> tryAutoConnect() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('routeUrl')) {
      return false;
    }
    final url = prefs.getString('routeUrl');
    final result = await establishConnection(url);
    if (result == 'success') {
      _isConnected = true;
      _routeUrl = url;
    } else {
      _isConnected = false;
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<String> uploadImage(File image, Function updateProgress) async {
    final uri = Uri.parse(_routeUrl + "/upload");
    final request = http.MultipartRequest("POST", uri);
    final contentLength = await image.length();
    int bytes = 0;
    final streamTransformer = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        updateProgress(bytes / contentLength);
        sink.add(data);
      },
    );
    final stream =
        http.ByteStream(image.openRead()).transform(streamTransformer);
    final multipartFile = http.MultipartFile(
      'image',
      stream,
      contentLength,
      filename: path.basename(image.path),
    );
    request.files.add(multipartFile);
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        return "success";
      } else {
        return "failed";
      }
    } catch (e) {
      return "";
    }
  }

  void disconnect() {
    _isConnected = false;
    notifyListeners();
  }

  Future<List> getPredictions(String imageName, String imagePath) async {
    final url = _routeUrl + "/predict";
    try {
      final response =
          await http.post(url, body: json.encode({"imageName": imageName}));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == "success") {
          File file = new File(imagePath);
          final imageResponse = await http.post(_routeUrl + "/download",
              body: json.encode({"imageName": imageName}));
          if (imageResponse.statusCode == 200) {
            await file.writeAsBytes(imageResponse.bodyBytes);
            await FileImage(file).evict();
          }
          return [responseData['predictions'], responseData['count']];
        } else {
          return ["failed"];
        }
      } else {
        return ["failed"];
      }
    } catch (e) {
      return ["failed"];
    }
  }
}
