import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  List<FileSystemEntity> allFiles = [];
  String? selectedDirectory;
  DateTime? start;

  DateTime? end;
  bool showDateTime = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getDateTime() {
    return end!.difference(start!).inMicroseconds;
  }

  getDirectory() async {
    selectedDirectory = await FilePicker.platform.getDirectoryPath();
    await fetchFiles();
  }

  fetchFiles() async {
    if (selectedDirectory != null) {
      final dir = Directory(selectedDirectory!);
      final List<FileSystemEntity> entities = await dir.list().toList();

      setState(() {
        allFiles = entities;
      });
    }
    setState(() {
      showDateTime = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: width * .4,
          height: height,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Row(children: [
                  Center(
                    child: Container(
                      width: width * .28,
                      height: 20,
                      child: Text(
                          selectedDirectory == null ? "" : selectedDirectory!),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        await getDirectory();
                      },
                      child: const Text("Choose directory"))
                ]),
              ),
              if (allFiles.isNotEmpty) ...[
                const Text(
                  "List of files",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                    height: height * .8,
                    child: ListView.builder(
                        itemCount: allFiles.length,
                        itemBuilder: ((context, index) => Text(
                              allFiles[index].path.split("\\").last,
                              textAlign: TextAlign.center,
                            )))),
                if (showDateTime)
                  Text(
                    "Time taken ${getDateTime()}μs",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                SizedBox(
                  width: width * .4,
                  child: ElevatedButton(
                      onPressed: () async {
                        List unique = [];
                        setState(() {
                          start = DateTime.now();
                        });
                        for (var i = 0; i < allFiles.length; i++) {
                          if (allFiles[i].path.endsWith("BIN") ||
                              allFiles[i].path.endsWith("bin")) {
                            continue;
                          }
                          var filehash = md5.convert(
                              await File(allFiles[i].path).readAsBytes());
                          if (!unique.contains(filehash)) {
                            unique.add(filehash);
                          } else {
                            await File(allFiles[i].path).delete();
                          }
                          print(filehash);
                        }
                        setState(() {
                          end = DateTime.now();
                        });
                        await fetchFiles();
                        setState(() {
                          showDateTime = true;
                        });
                      },
                      child: const Text("Delete Duplecate Files")),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
