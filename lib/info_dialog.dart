// github_info_popup.dart
import 'package:flutter/material.dart';

void showGitHubInfoPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title:
            Text('Information', style: Theme.of(context).textTheme.titleLarge),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Versions:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text('EyeSpy v1.0.0'),
              Text('Flutter v3.3.0'),
              Text('Unstable Development Release'),
              SizedBox(height: 10),
              Text('Contributors:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text('Team 2106, WindingMotor'),
              SizedBox(height: 10),
              Text('Other:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text('GitHub: https://github.com/yourusername/yourrepo'),
              SizedBox(height: 5),
              Text('License: MIT'),
              SizedBox(height: 5),
              Text('Copyright (c) 2024 WindingMotor'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}
