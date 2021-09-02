import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Auto extends StatefulWidget {
  const Auto({Key? key}) : super(key: key);

  @override
  _AutoState createState() => _AutoState();
}

class _AutoState extends State<Auto> {
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                //download only when permission is granted
                if (await Permission.manageExternalStorage
                    .request()
                    .isGranted) {
                  Directory? appDocDir = await getExternalStorageDirectory();

                  String newPath = "";
                  List<String> paths = appDocDir!.path.split("/");
                  for (int x = 1; x < paths.length; x++) {
                    print(paths[x]);
                    String folder = paths[x];
                    if (folder != "Android") {
                      newPath += "/" + folder;
                    } else {
                      break;
                    }
                  }
                  newPath = newPath + "/Download";
                  appDocDir = Directory(newPath);

                  final task = await _download(appDocDir.path);
                  await _openFile(task!);
                }
              },
              child: Text('Download'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFile(String task) async {
    if (await FlutterDownloader.open(taskId: task)) {
      print('Open');
    } else {
      print('Cant Open');
    }
  }

  Future<String?> _download(String path) async {
    return await FlutterDownloader.enqueue(
      url: 'https://file-examples-com.github.io/uploads/2017/02/zip_10MB.zip',
      savedDir: path,
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
  }
}
