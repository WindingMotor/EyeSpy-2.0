import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:path/path.dart' as p;

Future<void> openPathPlanner(BuildContext context) async {
  final localDocumentDirectory = await getApplicationDocumentsDirectory();
  final pathPlannerPath =
      p.join(localDocumentDirectory.path, 'EyeSpy', 'PathPlanner');

  // Check if PathPlanner exists
  final pathPlannerExists = await Directory(pathPlannerPath).exists();

  if (!pathPlannerExists) {
    print('PathPlanner does not exist. Downloading...');

    // Determine the OS and download the correct version
    final os = Platform.isLinux ? 'Linux' : 'Windows';
    final url = Uri.parse(
        'https://github.com/mjansen4857/pathplanner/releases/download/2024.1.7/PathPlanner-$os-v2024.1.7.zip');

    // Download the zip file
    final response = await http.get(url);

    // Decode the zip file
    final archive = ZipDecoder().decodeBytes(response.bodyBytes);

    // Create the temporary folder if it doesn't exist
    await Directory(pathPlannerPath).create(recursive: true);

    // Iterate over the entries in the archive and write them to the target directory
    for (final entry in archive) {
      final filePath = p.join(pathPlannerPath, entry.name);
      if (entry.isFile) {
        final outputFile = File(filePath);
        await outputFile.create(recursive: true);
        await outputFile.writeAsBytes(entry.content);
      } else {
        await Directory(filePath).create(recursive: true);
      }
    }
  }

  // Assuming the path planner executable is now ready to be opened
  print('PathPlanner is ready to be opened.');

  // Construct the full path to the executable
  final executablePath = p.join(
      pathPlannerPath, 'pathplanner'); // Adjust the executable name as needed

  final isLinux = Platform.isLinux ? true : false;

  if (isLinux) {
    // Change the permissions of the executable to make it runnable
    final chmodResult = await Process.run('chmod', ['+x', executablePath]);

    if (chmodResult.exitCode != 0) {
      print('Failed to change permissions: ${chmodResult.stderr}');
      return;
    }
  }

  // Execute the PathPlanner binary
  final result = await Process.run(executablePath, []);

  // Handle the result
  if (result.exitCode != 0) {
    print('Failed to open PathPlanner: ${result.stderr}');
  } else {
    print('PathPlanner opened successfully');
  }
}

void selectLive(String directory) async {
  // Get the application documents directory
  final localDocumentsDirectory = await getApplicationDocumentsDirectory();

  // Construct the source and destination paths
  final srcDeployFolder = Directory('${directory}/src/main/deploy');
  final destFolder = Directory('${localDocumentsDirectory.path}/EyeSpy_Live');

  // Ensure the destination folder exists
  await destFolder.create(recursive: true);

  // List all items in the source directory
  final items = srcDeployFolder.listSync();

  // Iterate over each item and copy it to the destination
  for (var item in items) {
    if (item is File) {
      final newPath = destFolder.path + '/' + item.path.split('/').last;
      await item.copy(newPath);
    }
  }

  print('Contents moved to EyeSpy_Live successfully.');
}
