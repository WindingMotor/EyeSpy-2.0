import 'dart:convert';
import 'dart:io';
import 'package:eyespy/clone_repo_dialog.dart';
import 'package:eyespy/details_page.dart';
import 'package:eyespy/info_dialog.dart';
import 'package:eyespy/path_viewer.dart';
import 'package:eyespy/pathplanner_tool.dart';
import 'package:eyespy/project_analyzer.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'git_tool.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late Future<Iterable<Directory>> _futureDirectories;

  @override
  void initState() {
    super.initState();
    _futureDirectories = _loadDirectories();
  }

  Future<Iterable<Directory>> _loadDirectories() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/EyeSpy/Cloned';
    return Directory(path).listSync().whereType<Directory>();
  }

  void refreshDirectories() {
    setState(() {
      _futureDirectories = _loadDirectories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Aligns children along the horizontal axis
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      showGitHubInfoPopup(context);
                    },
                  ),
                  const SizedBox(width: 15),
                  const Text('Eye Spy'),
                ],
              ),
              FutureBuilder<double>(
                future: getTotalCloneDirectorySizeInMB(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Show a loading indicator while waiting
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Row(
                      children: [
                        Text(
                            'Total at ${snapshot.data?.toStringAsFixed(2) ?? 'N/A'} MB',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium), // Total size on the right
                        const SizedBox(width: 5),
                        const Icon(Icons.storage),
                        const SizedBox(width: 12),

                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: () {
                            refreshDirectories();
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
        body: FutureBuilder<Iterable<Directory>>(
          future: _futureDirectories,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final directories = snapshot.data ?? [];
              return ListView.builder(
                itemCount: directories.length,
                itemBuilder: (context, index) {
                  final directory = directories.elementAt(index);
                  final analyzer = ProjectAnalyzer(directory.path);
                  return ListTile(
                      leading:
                          const Icon(Icons.folder), // Folder icon on the left
                      subtitle: /* row */ Row(
                        children: [
                          Text('${directory.path.split('/').last}'),
                          const SizedBox(width: 12),
                          Text('Year: ${analyzer.getProjectYear().toString()}'),
                          const SizedBox(width: 12),
                          Text('Language: ${analyzer.getProjectLang()}'),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: kDefaultFontSize,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    // Temp direct path for testing
                                    builder: (context) => ProjectDetailsPage(
                                        directoryPath: directory.path)),
                              );
                            },
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text('${analyzer.numberOfPaths()} paths'),
                              const SizedBox(width: 12),
                              Text('${analyzer.numberOfAutos()} autos'),
                            ],
                          ),
                          const SizedBox(width: 15),
                          FutureBuilder<double>(
                            future: getDirectorySizeInMB(directory.path),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData) {
                                  // Ensure snapshot.data is not null before calling toStringAsFixed
                                  return Text(
                                      '${snapshot.data?.toStringAsFixed(2) ?? 'N/A'} MB');
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                              }
                              return CircularProgressIndicator(); // Show a loading indicator while fetching size
                            },
                          ),
                          const SizedBox(
                              width: 5), // Space between size and delete icon
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final result =
                                  await deleteClonedRepository(directory.path);
                              if (result) {
                                print('Deleted ${directory.path}');
                                refreshDirectories(); // Refresh the directories list
                              } else {
                                print('Failed to delete ${directory.path}');
                              }
                            },
                          ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Text('Team ${analyzer.getTeamNumber().toString()} '),
                          IconButton(
                            icon: const Icon(
                              Icons.open_in_new,
                              size: kDefaultFontSize,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // Temp direct path for testing
                                  builder: (context) => PathViewer(
                                      filePath:
                                          '/home/isaac/Documents/EyeSpy/Cloned/SwerveDriveAdvantage2024/src/main/deploy/pathplanner/paths/PP_Forward.path',
                                      backgroundImageAsset:
                                          'images/field24.png'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 15),
                          // Text to explain button, smaller font
                        ],
                      ));
                },
              );
            }
          },
        ),
        // A new floating button row
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'fab_clone', // Unique tag for the clone button
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // Also refesh directories after dialog is closed
                    return CloneRepoDialog();
                  },
                );
              },
              child: const Icon(Icons.add_link_rounded),
            ),
            const SizedBox(width: 10),
          ],
        )
// Floating button here
        );
  }
}
