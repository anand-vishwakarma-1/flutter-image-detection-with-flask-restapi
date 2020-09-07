import 'package:flutter/material.dart';

import 'snack_bar.dart';
import '../widgets/server_input.dart';


void connectToServer(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: ServerInput(),
        );
      },
    ).then((value) {
      if (value == "success") {
        showSnackBar(ctx, 'Connection Established Successfully');
      } else {
        showSnackBar(ctx, 'There was an error while Connecting!');
      }
    });
  }