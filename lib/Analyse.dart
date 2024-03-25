
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import './messages/mooksviewer.pb.dart';

import 'provider/themeprovider.dart';
import 'provider/rawimageprovider.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'dart:typed_data';

class analysePage extends StatefulWidget {
  const analysePage({super.key});

  @override
  State<analysePage> createState() => _analysePageState();
}

class HistogramData {
  HistogramData(this.idx, this.value);
  final int idx;
  final int value;
}


class _analysePageState extends State<analysePage> {

  @override
  Widget build(BuildContext context) {
    final rawImageProvider = Provider.of<RawImageProvider>(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Prevideo(),
            Center(
              child: StreamBuilder(
                stream: MessageRaw.rustSignalStream,
                builder: (context, snapshot) {
                  final rustSignal = snapshot.data;
                  if (rustSignal == null) { return Text("-"); }
              
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
            ),
          ],
        ),
      ],
    );
  }
}

class Prevideo extends StatelessWidget {
  const Prevideo({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
          width: msg.width.toDouble() / 3,
          height: msg.height.toDouble() / 3,
          
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