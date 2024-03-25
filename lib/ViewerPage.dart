
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';


import './messages/mooksviewer.pb.dart';

import 'provider/themeprovider.dart';
import 'provider/rawimageprovider.dart';

import 'Display.dart';


class analysePage extends StatefulWidget {
  const analysePage({super.key});

  @override
  State<analysePage> createState() => _analysePageState();
}

class _analysePageState extends State<analysePage> {
  @override
  Widget build(BuildContext context) {
    final rawImageProvider = Provider.of<RawImageProvider>(context);

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
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
                  width: msg.width.toDouble() / 2,
                  height: msg.height.toDouble() / 2,
                  
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
          ),
          StreamBuilder(
            stream: MessageRaw.rustSignalStream,
            builder: (context, snapshot) {
              final rustSignal = snapshot.data;
              if (rustSignal == null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("_"),
                    Text("_"),
                    Text("_"),
                    Text("_"),
                    Text("_"),
                  ],
                );
              }
          
              final msg = rustSignal.message;
              final _Height = msg.height;
              final _Width = msg.width;
              final _curidx = msg.curidx;
              final _endidx = msg.endidx;
              final _fps = msg.fps;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("$_Width x $_Height"),
                  Text("$_curidx / $_endidx (" + ((_curidx / _endidx * 1000).ceil() / 10).toString() + "%)"),
                  Text("$_fps ms"),
                ],
              );
            }
          ),
        ],
      ),
    );
  }
}


class DropPage extends StatefulWidget {
  const DropPage({super.key});

  @override
  State<DropPage> createState() => _DropPageState();
}

class _DropPageState extends State<DropPage> {

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
        DisaplyArea(),
      ],
    );
  }
}
