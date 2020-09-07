import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/flask_provider.dart';

class ServerInput extends StatefulWidget {
  @override
  _ServerInputState createState() => _ServerInputState();
}

class _ServerInputState extends State<ServerInput> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isConnecting = false;

  void _establishConnection() async {
    final isValid = _formKey.currentState.validate();
    if (isValid) {
      setState(() {
        _isConnecting = true;
      });
      final status = await Provider.of<FLaskProvider>(context, listen: false)
          .establishConnection(_urlController.text);
      Navigator.of(context).pop(status);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _urlController.text = Provider.of<FLaskProvider>(context,listen: false).routeUrl;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 10,
        child: Container(
          margin: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 15,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Server URL'),
                  controller: _urlController,
                  onFieldSubmitted: (_) => _establishConnection,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a url';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 50),
                Container(
                  child: _isConnecting
                      ? CircularProgressIndicator()
                      : RaisedButton(
                          onPressed: _establishConnection,
                          child: Text('Establish Connection'),
                          color: Theme.of(context).accentColor,
                          textColor: Colors.white,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
