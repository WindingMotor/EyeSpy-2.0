// CloneRepoDialog.dart
import 'package:flutter/material.dart';
import 'package:eyespy/git_tool.dart'; // Adjust the import path as necessary

class CloneRepoDialog extends StatefulWidget {
  @override
  _CloneRepoDialogState createState() => _CloneRepoDialogState();
}

class _CloneRepoDialogState extends State<CloneRepoDialog> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  bool _isCompleted = false;
  bool _hasError = false;

  Future<void> _cloneRepository() async {
    setState(() {
      _isLoading = true;
      _hasError = false; // Reset error state at the start of each attempt
    });

    try {
      bool isSuccess = await cloneRepository(_urlController.text.trim());
      setState(() {
        _isLoading = false;
        _isCompleted = isSuccess;
        _hasError = !isSuccess;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true; // Set to true if cloning fails
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Clone a Repository'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Information about how to obtain repo link
          Text(
            'Enter the base URL of the teams GitHub repository you want to clone.',
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Enter GitHub Repo URL',
              hintText: 'https://github.com/user/reponame',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_isCompleted)
                const Icon(Icons.check_circle_outline, color: Colors.green)
              else if (_hasError)
                const Icon(Icons.error,
                    color: Colors.red) // Display a red X icon on error
              else
                TextButton(
                  child: const Text('Clone'),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          await _cloneRepository();
                        },
                ),
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
