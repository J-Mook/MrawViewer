import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rinf/rinf.dart';
import './messages/generated.dart';

import './messages/mooksviewer.pb.dart';


class RGBPage extends StatefulWidget {
  const RGBPage({super.key});

  @override
  State<RGBPage> createState() => _RGBPageState();
}

class _RGBPageState extends State<RGBPage> {

  double _rsilder_value = 0.0;
  double _gsilder_value = 0.0;
  double _bsilder_value = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Divider(thickness: 2,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                    onPressed: () async {
                      InputMessage(
                        cmd: "Reset",
                        intData: 0,
                      ).sendSignalToRust(null);
                    },
                    child: Text("Reset")),
                OutlinedButton(
                  onPressed: () async {
                    InputMessage(
                      cmd: "+",
                      intData: 0,
                    ).sendSignalToRust(null);
                  },
                  child: Icon(Icons.add),
                ),
                TextButton(
                  onPressed: () {
                    InputMessage(
                      cmd: "-",
                      intData: 0,
                    ).sendSignalToRust(null);
                  },
                  child: Container(child: Icon(Icons.remove)),
                ),
              ],
            ),
            Slider(
              value: _rsilder_value,
              max: 256,
              onChanged:(value) {
                _rsilder_value = value;
                setState(() { });
                InputMessage(
                  cmd: "SetRGB",
                  intRData: _rsilder_value.toInt(),
                  intGData: _gsilder_value.toInt(),
                  intBData: _bsilder_value.toInt(),
                ).sendSignalToRust(null);
              },
            ),
            Slider(
              value: _gsilder_value,
              max: 256,
              onChanged:(value) {
                _gsilder_value = value;
                setState(() { });
                InputMessage(
                  cmd: "SetRGB",
                  intRData: _rsilder_value.toInt(),
                  intGData: _gsilder_value.toInt(),
                  intBData: _bsilder_value.toInt(),
                ).sendSignalToRust(null);
              },
            ),
            Slider(
              value: _bsilder_value,
              max: 256,
              onChanged:(value) {
                _bsilder_value = value;
                setState(() { });
                InputMessage(
                  cmd: "SetRGB",
                  intRData: _rsilder_value.toInt(),
                  intGData: _gsilder_value.toInt(),
                  intBData: _bsilder_value.toInt(),
                ).sendSignalToRust(null);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                    onPressed: () async {
                      InputMessage(
                        cmd: "Play",
                        intData: 0,
                      ).sendSignalToRust(null);
                    },
                    child: Icon(Icons.play_arrow)),
                OutlinedButton(
                    onPressed: () async {
                      InputMessage(
                        cmd: "Stop",
                        intData: 0,
                      ).sendSignalToRust(null);
                    },
                    child: Icon(Icons.pause)),
              ],
            ),
            Divider(thickness: 2,),
            StreamBuilder(
                stream: OutputMessage.rustSignalStream,
                builder: (context, snapshot) {
                  final rustSignal = snapshot.data;
                  if (rustSignal == null) {
                    return Text("Nothing received yet");
                  }

                  final msg = rustSignal.message;
                  final nums = msg.currentNumber;
                  return Text(nums.toString());
                }),
            StreamBuilder(
              stream: OutputImage.rustSignalStream,
              builder: (context, snapshot) {
                final rustSignal = snapshot.data;
                if (rustSignal == null) {
                  return Text("Nothing received yet");
                }

                final imageData = rustSignal.blob!;
                final msg = rustSignal.message;
                _rsilder_value = msg.rdata.toDouble();
                _gsilder_value = msg.gdata.toDouble();
                _bsilder_value = msg.bdata.toDouble();
                return Column(
                  children: [
                    Text("r:$_rsilder_value  g:$_gsilder_value  b:$_bsilder_value"),
                    Container(
                      margin: const EdgeInsets.all(20),
                      width: 256,
                      height: 256,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.0),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.memory(
                            imageData,
                            width: 256,
                            height: 256,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
            Divider(thickness: 2,),
          ],
        ),
      ),
    );
  }
}
