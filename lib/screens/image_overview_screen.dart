import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../providers/flask_provider.dart';
import '../providers/image_provider.dart';
import '../widgets/image_upload.dart';
import '../functions/snack_bar.dart';
import '../widgets/image_grid.dart';
import '../functions/server_connection.dart';

class ImageOverview extends StatefulWidget {
  static const routeName = "/";
  @override
  _ImageOverviewState createState() => _ImageOverviewState();
}

class _ImageOverviewState extends State<ImageOverview> {
  // bool _showFilters = true;
  void _addImage(BuildContext ctx) {
    final flask = Provider.of<FLaskProvider>(ctx, listen: false);
    if (flask.connection) {
      showModalBottomSheet(
          context: ctx,
          builder: (_) {
            return GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: ImageUpload(),
            );
          }).then((value) {
        showSnackBar(ctx, '');
      });
    } else {
      showSnackBar(ctx, 'Not Connected to Server');
    }
  }

  void loadIntialData() async {
    if (Provider.of<FLaskProvider>(context, listen: false).isIntialized) {
      return;
    }

    print("loadInitial");
    await Provider.of<ImageDataProvider>(context, listen: false).runOnce();
    await Provider.of<ImageDataProvider>(context, listen: false).loadFilters();
    await Provider.of<FLaskProvider>(context, listen: false).tryAutoConnect();
    Provider.of<FLaskProvider>(context, listen: false).toggleInitialized();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadIntialData();
  }

  Widget getTitle() {
    final filters =
        Provider.of<ImageDataProvider>(context, listen: false).filters;
    if (filters['predicted'] && filters['notPredicted']) {
      return const Text('All Images');
    } else if (filters['predicted']) {
      return const Text('Predicted Images');
    } else {
      return const Text('Not Predicted Images');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: getTitle(),
        actions: <Widget>[
          Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.add_a_photo),
              onPressed: () => _addImage(ctx),
            ),
          ),
          // IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      drawer: AppDrawer(),
      floatingActionButton: Consumer<FLaskProvider>(
        child: Container(),
        builder: (ctx, flaskHelper, ch) => flaskHelper.connection
            ? ch
            : FlatButton(
                onPressed: () => connectToServer(ctx),
                child: Text("Connect to Server"),
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: FutureBuilder(
        future: Provider.of<ImageDataProvider>(context, listen: false)
            .fetchImages(),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ImageGrid(),
      ),
    );
  }
}
