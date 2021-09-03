import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class Manual extends StatefulWidget {
  Manual({Key? key}) : super(key: key);

  @override
  _ManualState createState() => _ManualState();
}

class _ManualState extends State<Manual> {
  final String _fileUrl =
      "https://file-examples-com.github.io/uploads/2017/02/zip_10MB.zip";

  final String _fileName = "manual.zip";
  String _progress = "";

  List<Map<String, String>> listDownload = [];

  final Dio _dio = Dio();

  @override
  Widget build(BuildContext context) {
    print(_progress);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manual'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _download,
              child: _progress.isEmpty ? Text('Download 1') : Text(_progress),
            ),
          ],
        ),
      ),
    );
  }

  Future<Directory> _getLocalPath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();

    return appDocDir;
  }

  Future<void> _download() async {
    final dir = await _getLocalPath();

    final savePath = path.join(dir.path, _fileName);

    await _startDownload(savePath);
  }

  _startDownload(String savePath) async {
    final response = await _dio.download(_fileUrl, savePath,
        onReceiveProgress: _onReceiveProgress);
  }

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
      });
    }
  }
}
