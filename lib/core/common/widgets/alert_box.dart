import 'package:flutter/material.dart';

Future<void> showMyDialog(
    BuildContext context, VoidCallback onTap, String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Alert'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              onTap();
              Navigator.pop(context);
            },
            child: const Text('Ok'),
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
