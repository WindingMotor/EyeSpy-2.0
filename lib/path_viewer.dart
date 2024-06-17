import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PathData {
  final List<Waypoint> waypoints;
  final Map<String, dynamic> globalConstraints;
  final Map<String, dynamic> goalEndState;
  final bool reversed;
  final Map<String, dynamic>? previewStartingState;

  PathData({
    required this.waypoints,
    required this.globalConstraints,
    required this.goalEndState,
    this.reversed = false,
    this.previewStartingState,
  });

  factory PathData.fromJson(Map<String, dynamic> json) {
    var waypointsList = json['waypoints'] as List<dynamic>;
    List<Waypoint> waypoints =
        waypointsList.map((i) => Waypoint.fromJson(i)).toList();

    return PathData(
      waypoints: waypoints,
      globalConstraints: json['globalConstraints'],
      goalEndState: json['goalEndState'],
      reversed: json['reversed'],
      previewStartingState: json['previewStartingState'],
    );
  }
}

class Waypoint {
  final Map<String, double> anchor;
  final Map<String, double>? prevControl;
  final Map<String, double>? nextControl;
  final bool isLocked;
  final String? linkedName;

  Waypoint({
    required this.anchor,
    this.prevControl,
    this.nextControl,
    this.isLocked = false,
    this.linkedName,
  });

  factory Waypoint.fromJson(Map<String, dynamic> json) {
    return Waypoint(
      anchor: {
        'x': json['anchor']['x'] as double,
        'y': json['anchor']['y'] as double
      },
      prevControl: json['prevControl'] != null
          ? {
              'x': json['prevControl']['x'] as double,
              'y': json['prevControl']['y'] as double
            }
          : null,
      nextControl: json['nextControl'] != null
          ? {
              'x': json['nextControl']['x'] as double,
              'y': json['nextControl']['y'] as double
            }
          : null,
      isLocked: json['isLocked'] as bool,
      linkedName: json['linkedName'] as String?,
    );
  }
}

class PathPainter extends CustomPainter {
  final PathData pathData;
  final double scaleFactor;
  final double canvasHeight;
  final ui.Image backgroundImage;

  PathPainter(
      this.pathData, this.scaleFactor, this.canvasHeight, this.backgroundImage);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the background image
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      image: backgroundImage,
      fit: BoxFit.cover,
    );

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < pathData.waypoints.length - 1; i++) {
      final waypoint = pathData.waypoints[i];
      final nextWaypoint = pathData.waypoints[i + 1];

      final startPoint = Offset(
        waypoint.anchor['x']! * scaleFactor,
        canvasHeight - waypoint.anchor['y']! * scaleFactor,
      );
      final endPoint = Offset(
        nextWaypoint.anchor['x']! * scaleFactor,
        canvasHeight - nextWaypoint.anchor['y']! * scaleFactor,
      );

      if (waypoint.nextControl != null && nextWaypoint.prevControl != null) {
        final controlPoint1 = Offset(
          waypoint.nextControl!['x']! * scaleFactor,
          canvasHeight - waypoint.nextControl!['y']! * scaleFactor,
        );
        final controlPoint2 = Offset(
          nextWaypoint.prevControl!['x']! * scaleFactor,
          canvasHeight - nextWaypoint.prevControl!['y']! * scaleFactor,
        );

        final path = Path()
          ..moveTo(startPoint.dx, startPoint.dy)
          ..cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
              controlPoint2.dy, endPoint.dx, endPoint.dy);

        canvas.drawPath(path, paint);
      } else {
        canvas.drawLine(startPoint, endPoint, paint);
      }
    }

    for (final waypoint in pathData.waypoints) {
      final waypointOffset = Offset(
        waypoint.anchor['x']! * scaleFactor,
        canvasHeight - waypoint.anchor['y']! * scaleFactor,
      );
      canvas.drawCircle(waypointOffset, 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<PathData> parsePathFile(String filePath) async {
  final file = File(filePath);
  final contents = await file.readAsString();
  final jsonData = jsonDecode(contents);
  return PathData.fromJson(jsonData);
}

class PathViewer extends StatefulWidget {
  final String filePath;
  final String backgroundImageAsset;

  const PathViewer(
      {Key? key, required this.filePath, required this.backgroundImageAsset})
      : super(key: key);

  @override
  _PathViewerState createState() => _PathViewerState();
}

class _PathViewerState extends State<PathViewer> {
  late Future<PathData> _pathDataFuture;
  ui.Image? _backgroundImage;

  @override
  void initState() {
    super.initState();
    _pathDataFuture = parsePathFile(widget.filePath);
    _loadBackgroundImage();
  }

  Future<void> _loadBackgroundImage() async {
    final ByteData data = await rootBundle.load(widget.backgroundImageAsset);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data.buffer.asUint8List(), completer.complete);
    _backgroundImage = await completer.future;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Path Visualization'),
      ),
      body: FutureBuilder<PathData>(
        future: _pathDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _backgroundImage == null) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  painter: PathPainter(snapshot.data!, 50,
                      constraints.maxHeight, _backgroundImage!),
                );
              },
            );
          }
        },
      ),
    );
  }
}
