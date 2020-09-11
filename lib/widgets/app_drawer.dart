import 'package:flask_test/functions/snack_bar.dart';
import 'package:flask_test/providers/flask_provider.dart';
import 'package:flask_test/screens/filters_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Settings'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Images'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.filter_list),
            title: const Text('Filters'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(FiltersScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('Disconnect Current Server'),
            onTap: () {
              if (Provider.of<FLaskProvider>(context, listen: false)
                  .connection) {
                Provider.of<FLaskProvider>(context, listen: false).disconnect();
                Navigator.pop(context);
                showSnackBar(context, "Server Disconnected");
              } else {
                Navigator.pop(context);
                showSnackBar(context, "No Server is Connected");
              }
            },
          ),
        ],
      ),
    );
  }
}
