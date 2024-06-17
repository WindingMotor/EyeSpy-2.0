// details_page.dart
import 'package:flutter/material.dart';
import 'package:eyespy/project_analyzer.dart';
import 'package:eyespy/git_tool.dart';

/*
class DetailsPage extends StatefulWidget {
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Future<List<String>> _directoriesFuture;
  String? _selectedDirectory;

  @override
  void initState() {
    super.initState();
    _directoriesFuture = getClonedDirectories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Project'),
      ),
      body: FutureBuilder<List<String>>(
        future: _directoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final directories = snapshot.data ?? [];
            return ListView.builder(
              itemCount: directories.length,
              itemBuilder: (context, index) {
                final directory = directories[index];
                return ListTile(
                  title: Text(directory.split('/').last),
                  onTap: () {
                    setState(() {
                      _selectedDirectory = directory;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailsPage(directoryPath: _selectedDirectory),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
*/
class ProjectDetailsPage extends StatelessWidget {
  final String directoryPath;

  const ProjectDetailsPage({super.key, required this.directoryPath});

  @override
  Widget build(BuildContext context) {
    final analyzer = ProjectAnalyzer(directoryPath);
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Details'),
      ),
      body: FutureBuilder(
        future: Future.wait([
          analyzer.listPaths(),
          analyzer.listAutos(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final pathNames = snapshot.data?[0] as List<String>;
            final autoNames = snapshot.data?[1] as List<String>;
            return ListView(
              children: [
                ListTile(
                  title: Text('Team Number: ${analyzer.getTeamNumber()}'),
                ),
                ListTile(
                  title: Text('Year: ${analyzer.getProjectYear()}'),
                ),
                ListTile(
                  title: Text('Language: ${analyzer.getProjectLang()}'),
                ),
                // Additional list tiles...
              ],
            );
          }
        },
      ),
    );
  }
}
