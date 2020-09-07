import 'package:flask_test/functions/snack_bar.dart';
import 'package:flask_test/providers/image_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';

class FiltersScreen extends StatefulWidget {
  static const routeName = '/filters';
  @override
  _FiltersScreenState createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  bool _predicted = true;
  bool _notPredicted = true;
  bool _reverse = false;
  bool _predictionSort = false;

  @override
  initState() {
    final filters =
        Provider.of<ImageDataProvider>(context, listen: false).filters;
    _predicted = filters['predicted'];
    _notPredicted = filters['notPredicted'];
    _reverse = filters['reverse'];
    _predictionSort = filters['predictionSort'];
    super.initState();
  }

  Widget _buildSwitchListTile(
    String title,
    String description,
    bool currentValue,
    Function updateValue,
  ) {
    return SwitchListTile(
      title: Text(title),
      value: currentValue,
      subtitle: Text(
        description,
      ),
      onChanged: updateValue,
    );
  }

  void _applyFilters(BuildContext ctx) {
    Provider.of<ImageDataProvider>(ctx, listen: false).updateFilters(
      pred: _predicted,
      notPred: _notPredicted,
      rev: _reverse,
      predSort: _predictionSort,
    );
    showSnackBar(ctx, "Filters Updated");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filters'),
        actions: <Widget>[
          Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.save),
              onPressed: () => _applyFilters(ctx),
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              'Filter or Sort your Images.',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                _buildSwitchListTile(
                  'Predicted',
                  'Only Images with Completed Prediction.',
                  _predicted,
                  (newValue) {
                    setState(() {
                    if (!_notPredicted && !newValue) {
                      _notPredicted = true;
                    }
                      _predicted = newValue;
                    });
                  },
                ),
                _buildSwitchListTile(
                  'Not Predicted',
                  'Only Images with Prediction Remaining.',
                  _notPredicted,
                  (newValue) {
                    setState(() {
                    if (!_predicted && !newValue) {
                      _predicted = true;
                    }
                      _notPredicted = newValue;
                    });
                  },
                ),
                _buildSwitchListTile(
                  'Sort Reverse',
                  'Sort Images by latest uploaded at last.',
                  _reverse,
                  (newValue) {
                    setState(() {
                      _reverse = newValue;
                    });
                  },
                ),
                _buildSwitchListTile(
                  'Sort Prediction Count',
                  'Sort Images by Highest Prediction Count.',
                  _predictionSort,
                  (newValue) {
                    setState(() {
                      _predictionSort = newValue;
                    });
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 2 - 80),
                  child: Builder(
                    builder: (ctx) => FlatButton.icon(
                      onPressed: () => _applyFilters(ctx),
                      icon: Icon(Icons.save),
                      label: Text("Apply Filters"),
                      color: Theme.of(context).accentColor,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
