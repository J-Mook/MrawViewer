import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rinf/rinf.dart';
import './messages/generated.dart';

import 'package:file_picker/file_picker.dart';

import './messages/mooksviewer.pb.dart';
import './RGBpage.dart';

void main() async {
  await initializeRust();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "jmook",
      initialRoute: '/',
      routes: {
        '/' : (context) => MRawViewer(),
        '/home' : (context) => MRawViewer(),
        '/rgb' : (context) => RGBPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MRawViewer extends StatelessWidget {
  const MRawViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mook's Viewer"),
        actions: <Widget>[
          IconButton(
            onPressed:() {
              Navigator.pushNamed(context, '/rgb');
            },
            icon: const Icon(Icons.palette))
        ],
      ),
      body: ViewerBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // setState(() { Navigator.pushNamed(context, '/RandColor'); });
        },
        child: const Icon(Icons.link),
      ),
    );
  }
}

class ViewerBody extends StatefulWidget {
  const ViewerBody({super.key});

  @override
  State<ViewerBody> createState() => _ViewerBodyState();
}

class _ViewerBodyState extends State<ViewerBody> {

  String mrawpath = "";
  String str_height = "";
  String str_width = "";
  int height = 513;
  int width = 640;


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10,width: 1100,),
        SizedBox(height: 35,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 150),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Width',
                    ),
                    onChanged: (value) { if (value.isNotEmpty){ str_width = value; } },
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 150),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Height',
                    ),
                    onChanged: (value) { if (value.isNotEmpty){ str_height = value; } }
                  ),
                ),
              ),
              // Flexible(
              //   fit: FlexFit.tight,
              //   child: TextField(
              //     decoration: InputDecoration(
              //       border: OutlineInputBorder(),
              //       labelText: mrawpath,
              //     ),
              //     onChanged: (value) {
              //       mrawpath = value;
              //     },
              //   ),
              // ),
              IconButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                  if (result != null) {
                    mrawpath = result.files.single.path!;
                  }

                  // FilePickerResult? result = await FilePicker.platform.pickFiles();
                  // if (result != null) {
                  //   PlatformFile file = result.files.first;
                  //   print(file.name);
                  //   print(file.bytes);
                  //   print(file.size);
                  //   print(file.extension);
                  //   print(file.path);
                  // } else {
                  //   // User canceled the picker
                  // }
                  setState(() { });
                },
                icon: Icon(Icons.file_open)
              )
            ],
          ),
        ),
        Text(mrawpath),
        ElevatedButton(
          onPressed:() {
            MessageOpenFile(
              filepath: mrawpath,
              height: int.parse(str_height) > 0 ? int.parse(str_height) : 0,
              width: int.parse(str_width) > 0 ? int.parse(str_width) : 0,
              byte: 0,
              head: 0,
              tail: 0
            ).sendSignalToRust(null);
          },
          child: Text("Open")
        ),
        VideoArea(),
        PlayController(),
      ],
    );
  }
}

class VideoArea extends StatefulWidget {
  const VideoArea({super.key});

  @override
  State<VideoArea> createState() => _VideoAreaState();
}

class _VideoAreaState extends State<VideoArea> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MessageRaw.rustSignalStream,
      builder: (context, snapshot) {
        final rustSignal = snapshot.data;
        if (rustSignal == null) { return Text("Nothing received yet"); }

        final imageData = rustSignal.blob!;
        final msg = rustSignal.message;
        return Container(
          margin: const EdgeInsets.all(20),
          width: msg.width.toDouble(),
          height: msg.height.toDouble(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Image.memory(
                imageData,
                width: msg.width.toDouble(),
                height: msg.height.toDouble(),
                gaplessPlayback: true,
              ),
            ),
          ),
        );
      }
    );
  }
}

class PlayController extends StatefulWidget {
  const PlayController({super.key});

  @override
  State<PlayController> createState() => _PlayControllerState();
}

class _PlayControllerState extends State<PlayController> {
  @override
  Widget build(BuildContext con1text) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed:() {
              MessagePlayControl(cmd: 'Play').sendSignalToRust(null);
            },
            icon: Icon(Icons.play_arrow)
          ),
          IconButton(
            onPressed:() {
              MessagePlayControl(cmd: 'Puase').sendSignalToRust(null);
            },
            icon: Icon(Icons.pause)
          ),
          IconButton(
            onPressed:() {
              MessagePlayControl(cmd: 'Stop').sendSignalToRust(null);
            },
            icon: Icon(Icons.stop)
          ),
          IconButton(
            onPressed:() {
              MessagePlayControl(cmd: 'Close').sendSignalToRust(null);
            },
            icon: Icon(Icons.close)
          ),

        ],
      ),
    );
  }
}