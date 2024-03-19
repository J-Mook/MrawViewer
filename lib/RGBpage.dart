import 'package:flutter/cupertino.dart';
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

  List<Widget> _colorList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _colorList.length,
                itemBuilder:(context, index) => _colorList[index],
              ),
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
                    Divider(thickness: 2,),
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
                    Divider(thickness: 2,),
                    Text("r:$_rsilder_value  g:$_gsilder_value  b:$_bsilder_value"),
                    Container(
                      margin: const EdgeInsets.all(20),
                      width: 256,
                      height: 256,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.0),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Stack(
                            alignment: Alignment.center,
                            children:[
                              Image.memory(
                                imageData,
                                width: 256,
                                height: 256,
                                gaplessPlayback: true,
                              ),
                              IconButton(
                                onPressed:() {
                                  _colorList.insert(0,
                                    FittedBox(
                                      fit: BoxFit.fill,
                                      child: Container(width: 20, height: 20,
                                        margin: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(3)),
                                          color: Color.fromARGB(255, _rsilder_value.toInt(), _gsilder_value.toInt(), _bsilder_value.toInt()),
                                        ),
                                      ),
                                    )
                                  );
                                  setState(() { });
                                },
                                icon: Icon(Icons.add_box)
                              ),
                            ] 
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
