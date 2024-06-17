// git_tool.dart
import 'dart:io';
import 'package:eyespy/project_analyzer.dart';
import 'package:path_provider/path_provider.dart';

Future<bool> cloneRepository(String url) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final repoPath = '${directory.path}/EyeSpy/Cloned/${url.split('/').last}';
    await Directory(repoPath).create(recursive: true);
    final cloneCommand = 'git clone $url $repoPath';
    await Process.run('bash', ['-c', cloneCommand]).then((result) {
      if (result.exitCode != 0) {
        throw Exception('Failed to clone repository');
      }
    });
    print('Repository cloned successfully!');

    return true;
  } catch (e) {
    print('Error cloning reposer sitory: $e');
    return false;
  }
}

Future<int> countRepositoriesWithVendorDep() async {
  final directory = await getApplicationDocumentsDirectory();
  final reposDir = Directory('${directory.path}/EyeSpy/Cloned');
  if (!await reposDir.exists()) {
    return 0; // Return 0 if the Cloned directory doesn't exist
  }

  final repos =
      await reposDir.list().where((item) => item is Directory).toList();
  int count = 0;

  for (var repo in repos) {
    final analyzer = ProjectAnalyzer(repo.path);
    if (analyzer.hasVendordeps()) {
      count++;
    }
  }

  return count;
}

Future<bool> deleteClonedRepository(String url) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final repoPath = '${directory.path}/EyeSpy/Cloned/${url.split('/').last}';
    final repoDirectory = Directory(repoPath);

    if (await repoDirectory.exists()) {
      await repoDirectory.delete(recursive: true);
      print('Repository deleted successfully!');
      return true;
    } else {
      print('Repository does not exist.');
      return false;
    }
  } catch (e) {
    print('Error deleting repository: $e');
    return false;
  }
}

Future<double> getDirectorySizeInMB(String directoryPath) async {
  try {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      print('Directory does not exist: $directoryPath');
      return 0.0;
    }

    double totalSizeInBytes = 0;

    await for (var entity in directory.list(recursive: true)) {
      if (entity is File) {
        totalSizeInBytes += entity.statSync().size;
      }
    }

    final sizeInMB =
        totalSizeInBytes / (1024 * 1024); // Convert bytes to megabytes
    return sizeInMB;
  } catch (e) {
    print('Error getting directory size: $e');
    return 0.0;
  }
}

Future<double> getTotalCloneDirectorySizeInMB() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final reposDir = Directory('${directory.path}/EyeSpy/Cloned');
    if (!await reposDir.exists()) {
      print('Cloned directory does not exist.');
      return 0.0;
    }

    double totalSizeInBytes = 0;

    await for (var entity in reposDir.list(recursive: true)) {
      if (entity is File) {
        // Ensure we're only considering files for size calculation
        totalSizeInBytes +=
            await entity.length(); // Use length() to get file size
      }
    }

    final totalSizeInMB =
        totalSizeInBytes / (1024 * 1024); // Convert bytes to megabytes
    return totalSizeInMB;
  } catch (e) {
    print('Error calculating total clone directory size: $e');
    return 0.0;
  }
}

Future<List<String>> getClonedDirectories() async {
  final directory = await getApplicationDocumentsDirectory();
  final reposDir = Directory('${directory.path}/EyeSpy/Cloned');
  if (!await reposDir.exists()) {
    return []; // Return an empty list if the Cloned directory doesn't exist
  }

  final dirs = await reposDir
      .list()
      .where((item) => item is Directory)
      .map((dir) => dir.path)
      .toList();
  return dirs;
}
