import 'dart:convert';
import 'dart:io';

class ProjectAnalyzer {
  final String directoryPath;

  ProjectAnalyzer(this.directoryPath);

  bool hasVendordeps() {
    final vendorDepsDir = Directory('$directoryPath/vendordeps');
    return vendorDepsDir.existsSync();
  }

  bool hasPathPlanner() {
    final pathPlannerDir = Directory('$directoryPath/.pathplanner');
    return pathPlannerDir.existsSync();
  }

  bool hasChoreo() {
    final choreoDir = Directory('$directoryPath/src/main/deploy/choreo');
    return choreoDir.existsSync();
  }

  int numberOfPaths() {
    final pathsDir =
        Directory('$directoryPath/src/main/deploy/pathplanner/paths');
    if (!pathsDir.existsSync()) {
      return 0;
    }
    final pathFiles = pathsDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.path'));
    return pathFiles.length;
  }

  int numberOfAutos() {
    final pathsDir =
        Directory('$directoryPath/src/main/deploy/pathplanner/autos');
    if (!pathsDir.existsSync()) {
      return 0;
    }
    final pathFiles = pathsDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.auto'));
    return pathFiles.length;
  }

  int getTeamNumber() {
    final prefsFile = File('$directoryPath/.wpilib/wpilib_preferences.json');
    if (prefsFile.existsSync()) {
      final prefsJson = prefsFile.readAsStringSync();
      final Map<String, dynamic> prefsMap = jsonDecode(prefsJson);
      return prefsMap['teamNumber'];
    }
    return -1;
  }

  String getProjectYear() {
    final prefsFile = File('$directoryPath/.wpilib/wpilib_preferences.json');
    if (prefsFile.existsSync()) {
      final prefsJson = prefsFile.readAsStringSync();
      final Map<String, dynamic> prefsMap = jsonDecode(prefsJson);
      return prefsMap['projectYear'] ?? 'Unknown';
    }
    return 'Unknown';
  }

  String getProjectLang() {
    final prefsFile = File('$directoryPath/.wpilib/wpilib_preferences.json');
    if (prefsFile.existsSync()) {
      final prefsJson = prefsFile.readAsStringSync();
      final Map<String, dynamic> prefsMap = jsonDecode(prefsJson);
      return prefsMap['currentLanguage'] ?? 'Unknown';
    }
    return 'Unknown';
  }

  Future<List<String>> listPaths() async {
    final pathsDir =
        Directory('$directoryPath/src/main/deploy/pathplanner/paths');
    if (!pathsDir.existsSync()) {
      return [];
    }
    final pathFiles = pathsDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.path'))
        .map((file) => file.path.split('/').last);
    return pathFiles.toList();
  }

  Future<List<String>> listAutos() async {
    final autosDir =
        Directory('$directoryPath/src/main/deploy/pathplanner/autos');
    if (!autosDir.existsSync()) {
      return [];
    }
    final autoFiles = autosDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.auto'))
        .map((file) => file.path.split('/').last);
    return autoFiles.toList();
  }

  String getPathLocation(String pathname) {
    return '$directoryPath/src/main/deploy/pathplanner/paths/$pathname';
  }

  String getAutoLocation(String autoName) {
    return '$directoryPath/src/main/deploy/pathplanner/autos/$autoName';
  }
}
