
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';


import './messages/mooksviewer.pb.dart';

import 'provider/themeprovider.dart';
import 'provider/rawimageprovider.dart';


class analysePage extends StatefulWidget {
  const analysePage({super.key});

  @override
  State<analysePage> createState() => _analysePageState();
}

class _analysePageState extends State<analysePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Center(child: VideoArea()),
          // context.watch<RawImageProvider>().ishoverImage ? Center(child: PlayController()) : Text(""),
        ],
      ),
    );
  }
}


class dropPage extends StatefulWidget {
  const dropPage({super.key});

  @override
  State<dropPage> createState() => _dropPageState();
}

class _dropPageState extends State<dropPage> {

  String showFileName = "";

  bool _dragging = false;

  Color uploadingColor = Colors.blue[100]!;
  Color defaultColor = Colors.grey[400]!;

  Container makeDropZone(){
    Color color = _dragging ? uploadingColor : defaultColor;
    return Container(
      height: 500,
      width: 600,
      margin: EdgeInsets.fromLTRB(10, 20, 20, 20),
      decoration: BoxDecoration(
        border: Border.all(width: 5, color: color,),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Drop Your ", style: TextStyle(color: color, fontSize: 20,),),
              Text(".mraw File", style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 20,),),
              Icon(Icons.insert_drive_file_rounded, color: color,),
              Text(" Here", style: TextStyle(color: color, fontSize: 20,),),
            ],
          ),
          Text("(*.mraw)", style: TextStyle(color: color,),),
          const SizedBox(height: 10,),
          Text(showFileName, style: TextStyle(color: defaultColor,),),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    final rawImageProvider = Provider.of<RawImageProvider>(context);

    return DropTarget(
      onDragDone: (detail) async {
        debugPrint('onDragDone:');
        if( detail != null && detail.files.isNotEmpty ){
          String fileName = detail.files.first.name;
          debugPrint(fileName);
          setState(() { showFileName = "Now File Name: $fileName"; });
          
          MessagePlayControl(cmd: 'Close', data: 0).sendSignalToRust(null);
          MessageOpenFile(
            filepath: detail.files.first.path,
            height: rawImageProvider.height,
            width: rawImageProvider.width,
            byte: 0,
            head: 0,
            tail: 0
          ).sendSignalToRust(null);

          rawImageProvider.isOpned = true;
          context.read<RawImageProvider>().setFileName(detail.files.first.path);
        }
      },
      onDragEntered: (detail) {
        setState(() {
          debugPrint('onDragEntered:');
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        debugPrint('onDragExited:');
        setState(() {
          _dragging = false;
        });
      },
      child: _dragging ? makeDropZone() : ViewerBody(),
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
  bool opened = false;
  final TextEditingController _controller_wid = TextEditingController();
  final TextEditingController _controller_hit = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final rawImageProvider = Provider.of<RawImageProvider>(context);
    if(_controller_wid.text.isEmpty)
      _controller_wid.text = rawImageProvider.width.toString();
    if(_controller_hit.text.isEmpty)
      _controller_hit.text = rawImageProvider.height.toString();

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
                    controller: _controller_wid,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Width',
                    ),
                    onChanged: (value) { if (value.isNotEmpty){ rawImageProvider.width = int.parse(value) > 0 ? int.parse(value) : 0; } },
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 150),
                  child: TextField(
                    controller: _controller_hit,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Height',
                    ),
                    onChanged: (value) { if (value.isNotEmpty){ rawImageProvider.height = int.parse(value) > 0 ? int.parse(value) : 0; }}
                  ),
                ),
              ),
              Spacer(),
              rawImageProvider.isOpned ? ElevatedButton(
                onPressed:() {
                  MessagePlayControl(cmd: 'Close', data: 0).sendSignalToRust(null);
                  rawImageProvider.isOpned = false;
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
                    height: rawImageProvider.height,
                    width: rawImageProvider.width,
                    byte: 0,
                    head: 0,
                    tail: 0
                  ).sendSignalToRust(null);

                  rawImageProvider.isOpned = true;
                  context.read<RawImageProvider>().setFileName(mrawpath);
                  // setState(() { });
                },
                child: Row( children: [ Icon(Icons.file_open), Text(" Open"), ], )
              ),
              ElevatedButton(
                onPressed:() {
                  MessagePlayControl(cmd: 'Encoding', data: 0).sendSignalToRust(null);
                  setState(() { });
                },
                child: Row( children: [ Icon(Icons.mp), Text(" mp4"), ], )
              )
            ],
          ),
        ),
        Divider(),
        // Text(mrawpath),
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
            // context.read<RawImageProvider>().setImageSize(640, 480);
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
          Text(context.watch<RawImageProvider>().filepath),
          SizedBox(height: rawImageProvider.height > (controllerSize + siderSize + 20) ? rawImageProvider.height - (controllerSize + siderSize + 20) : 0,),
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