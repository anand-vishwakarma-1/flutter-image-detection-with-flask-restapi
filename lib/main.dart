import 'package:flask_test/screens/filters_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/flask_provider.dart';
import './providers/image_provider.dart';
import './screens/image_overview_screen.dart';
import './screens/image_detail_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => ImageDataProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => FLaskProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Colors.blue[900],
        ),
        home: ImageOverview(),
        routes: {
          ImageDetail.routeName: (ctx) => ImageDetail(),
          FiltersScreen.routeName: (ctx) => FiltersScreen(),
        },
      ),
    );
  }
}
