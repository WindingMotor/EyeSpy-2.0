import 'package:eyespy/details_page.dart';
import 'package:eyespy/library_page.dart';
import 'package:eyespy/clone_repo_dialog.dart';
import 'package:eyespy/info_dialog.dart';
import 'package:eyespy/pathplanner_tool.dart';
import 'package:eyespy/project_analyzer.dart';
import 'package:flutter/material.dart';

import 'git_tool.dart';

void main() {
  runApp(const MyApp());

  final repoPath =
      '/home/isaac/Documents/EyeSpy/Cloned/SwerveDriveAdvantage2024';
  print('Repo Path: $repoPath');

  final analyzer = ProjectAnalyzer(repoPath);
  print('Has Vendordeps: ${analyzer.hasVendordeps()}');
  print('Has Path Planner: ${analyzer.hasPathPlanner()}');
  print('Has Choreo: ${analyzer.hasChoreo()}');
  print('Number of Paths: ${analyzer.numberOfPaths()}');

  print('Project Lang: ${analyzer.getProjectLang()}');
  print('Team Number: ${analyzer.getTeamNumber()}');
  print('Project Year: ${analyzer.getProjectYear()}');

  // Print out how many repos are in the cloned directory
  countRepositoriesWithVendorDep().then((count) {
    print('Number of repos with vendordeps: $count');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eye Spy',
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ThemeData.dark().colorScheme.copyWith(
            secondary: Colors.red.shade900, // Red accent color
            primary: Colors.red.shade900),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Bulo'),
          bodyMedium: TextStyle(fontFamily: 'Bulo'),
          bodySmall: TextStyle(fontFamily: 'Bulo'),
          titleSmall: TextStyle(fontFamily: 'Bulo Bold'),
          titleMedium: TextStyle(fontFamily: 'Bulo Bold'),
          titleLarge: TextStyle(fontFamily: 'Bulo Bold', color: Colors.white),
          displayLarge: TextStyle(fontFamily: 'Bulo Bold', color: Colors.white),
          displayMedium:
              TextStyle(fontFamily: 'Bulo Bold', color: Colors.white),
          displaySmall: TextStyle(fontFamily: 'Bulo Bold', color: Colors.white),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey[850], // Dark grey background
          contentTextStyle: const TextStyle(color: Colors.white), // White text
          behavior: SnackBarBehavior
              .floating, // Optional: makes the SnackBar float above the screen
        ),
      ),
      home: LibraryPage(),
    );
  }
}

/*
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eye Spy'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LibraryPage()),
                        );
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.width /
                            3, // Adjust the size to make it square
                        width: MediaQuery.of(context).size.width /
                            3, // Adjust the size to make it square
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(35), // Rounded corners
                          // Dark theme accent color
                          color: Theme.of(context).cardTheme.color,
                          // Accent color border
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.library_books, size: 40),
                            SizedBox(height: 10),
                            Text('Library', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // Open PathPlanner
                        openPathPlanner(context);
                      },
                      child: Container(
                        height: 100, // Set a fixed height for the container
                        width: 100, // Make the container square
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.map, size: 40), // Icon for PathPlanner
                            SizedBox(height: 10),
                            Text('Open PathPlanner',
                                style: TextStyle(fontSize: 18)), // Larger text
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // Clone Repository
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CloneRepoDialog();
                          },
                        );
                      },
                      child: Container(
                        height: 100, // Set a fixed height for the container
                        width: 100, // Make the container square
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.cloud_download,
                                size: 40), // Icon for Clone Repo
                            SizedBox(height: 10),
                            Text('Clone Repo',
                                style: TextStyle(fontSize: 18)), // Larger text
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/
