
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';


import './messages/mooksviewer.pb.dart';

import 'provider/themeprovider.dart';
import 'provider/rawimageprovider.dart';



class ViewerBody extends StatefulWidget {
  const ViewerBody({super.key});

  @override
  State<ViewerBody> createState() => _ViewerBodyState();
}

class _ViewerBodyState extends State<ViewerBody> {

  String mrawpath = "";
  String str_height = "";
  String str_width = "";
  bool opened = false;

  @override
  Widget build(BuildContext context) {
    final rawImageProvider = Provider.of<RawImageProvider>(context);

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
                    onChanged: (value) { if (value.isNotEmpty){ str_height = value; }}
                  ),
                ),
              ),
              Spacer(),
              opened ? ElevatedButton(
                onPressed:() {
                  MessagePlayControl(cmd: 'Close', data: 0).sendSignalToRust(null);
                  opened = false;
                  setState(() { });
                },
                child: Row( children: [ Icon(Icons.close), Text(" Close"), ], )
              ) : ElevatedButton(
                onPressed:() async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                  if (result != null) { mrawpath = result.files.single.path!; }

                  MessagePlayControl(cmd: 'Close', data: 0).sendSignalToRust(null);
                  MessageOpenFile(
                    filepath: mrawpath,
                    height: int.parse(str_height) > 0 ? int.parse(str_height) : 0,
                    width: int.parse(str_width) > 0 ? int.parse(str_width) : 0,
                    byte: 0,
                    head: 0,
                    tail: 0
                  ).sendSignalToRust(null);

                  rawImageProvider.height = int.parse(str_height) > 0 ? int.parse(str_height) : 0;
                  rawImageProvider.width = int.parse(str_width) > 0 ? int.parse(str_width) : 0;
                  opened = true;
                  context.read<RawImageProvider>().setFileName(mrawpath);
                  // setState(() { });
                },
                child: Row( children: [ Icon(Icons.file_open), Text(" Open"), ], )
              ),
            ],
          ),
        ),
        Divider(),
        Text(mrawpath),
        Stack(
          children: [
            Center(child: VideoArea()),
            context.watch<RawImageProvider>().ishoverImage ? Center(child: PlayController()) : Text(""),
          ],
        ),
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
  Widget build(BuildContext pcontext) {
    final rawImageProvider = Provider.of<RawImageProvider>(pcontext);

    return MouseRegion(
      onEnter: (event) { pcontext.read<RawImageProvider>().setHover(true); },
      onExit: (event) { pcontext.read<RawImageProvider>().setHover(false); },
      child: StreamBuilder(
        stream: MessageRaw.rustSignalStream,
        builder: (context, snapshot) {
          final rustSignal = snapshot.data;
          if (rustSignal == null) {
            context.read<RawImageProvider>().setImageSize(640, 480);
            return Container(
              margin: const EdgeInsets.all(20),
              width: 640,
              height: 480,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0),
                color: Colors.black,
              ),
            );
          }
      
          final imageData = rustSignal.blob!;
          final msg = rustSignal.message;
          context.read<RawImageProvider>().setImageSize(msg.width.toInt(), msg.height.toInt());
          context.read<RawImageProvider>().curidx = msg.curidx.toInt();
          // rawImageProvider.setIdx(msg.curidx.toInt());
          context.read<RawImageProvider>().maxidx = msg.endidx.toInt() - 1;

          return Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 7),
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
      ),
    );
  }
}

class PlayController extends StatefulWidget {
  const PlayController({super.key});

  @override
  State<PlayController> createState() => _PlayControllerState();
}

class _PlayControllerState extends State<PlayController> {
  static double controllerSize = 50;
  static double siderSize = 20;
  double _idx = 0;
  int _fps = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final rawImageProvider = Provider.of<RawImageProvider>(context);

    return MouseRegion(
      onEnter: (event) { context.read<RawImageProvider>().setHover(true); },
      onExit: (event) { context.read<RawImageProvider>().setHover(false); },
      child: Column(
        children: [
          SizedBox(height: rawImageProvider.height > (controllerSize + siderSize) ? rawImageProvider.height - (controllerSize + siderSize) : 0,),
          SizedBox(
            height: siderSize,
            width: rawImageProvider.width.toDouble(),
            child: StreamBuilder(
              stream: MessageRaw.rustSignalStream,
              builder: (context, snapshot) {
              final rustSignal = snapshot.data;
                if (rustSignal == null) { _idx = 0; }
                else{ _idx = rustSignal.message.curidx.toDouble(); _fps = rustSignal.message.fps.toInt();}
                return Slider(
                  value: _idx,
                  max: context.watch<RawImageProvider>().maxidx.toDouble(),
                  onChanged: (value) {
                    MessagePlayControl(cmd: 'Jump', data: value).sendSignalToRust(null);
                  },
                );
              }
            ),
          ),
          SizedBox(height: 5),
          Container(
            width: 200, height: controllerSize,
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? Color.fromARGB(142, 0, 0, 0) : Color.fromARGB(218, 255, 255, 255),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(context.watch<RawImageProvider>().filepath),
                // IconButton(
                //   onPressed:() {
                //     MessagePlayControl(cmd: 'Stop', data: 0).sendSignalToRust(null);
                //   },
                //   icon: Icon(Icons.stop)
                // ),
                IconButton(
                  onPressed:() {
                    MessagePlayControl(cmd: 'Dec', data: 0).sendSignalToRust(null);
                  },
                  icon: Icon(Icons.keyboard_arrow_left)
                ),
                !context.watch<RawImageProvider>().isPlay ?
                IconButton(
                  onPressed:() {
                    MessagePlayControl(cmd: 'Play', data: 0).sendSignalToRust(null);
                    context.read<RawImageProvider>().setPlay(true);
                  },
                  icon: Icon(Icons.play_arrow,)
                ) :
                IconButton(
                  onPressed:() {
                    MessagePlayControl(cmd: 'Pause', data: 0).sendSignalToRust(null);
                    context.read<RawImageProvider>().setPlay(false);
                  },
                  icon: Icon(Icons.pause)
                ),
                IconButton(
                  onPressed:() {
                    MessagePlayControl(cmd: 'Inc', data: 0).sendSignalToRust(null);
                  },
                  icon: Icon(Icons.keyboard_arrow_right)
                ),
                
              ],
            ),
          ),
          // StreamBuilder(
          //   stream: MessageRaw.rustSignalStream,
          //   builder: (context, snapshot) {
          //   final rustSignal = snapshot.data;
          //     if (rustSignal == null) { _fps = 0; }
          //     else{ _fps = rustSignal.message.fps.toInt();}
          //     return Text("$_fps ms", textAlign: TextAlign.end,);
          //   }
          // ),
        ],
      ),
    );
  }
}