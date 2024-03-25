import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import './messages/mooksviewer.pb.dart';

import 'provider/themeprovider.dart';
import 'provider/rawimageprovider.dart';


import 'package:flutter/cupertino.dart';

class DisaplyArea extends StatefulWidget {
  const DisaplyArea({super.key});

  @override
  State<DisaplyArea> createState() => _DisaplyAreaState();
}

class _DisaplyAreaState extends State<DisaplyArea> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Center(child: VideoArea()),
        context.watch<RawImageProvider>().ishoverImage ? Center(child: PlayController()) : Text(""),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text(context.watch<RawImageProvider>().filepath),
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
          SizedBox(height: 15),
        ],
      ),
    );
  }
}