import './mooksviewer.pb.dart' as mooksviewer;
// ignore_for_file: unused_import

import 'dart:typed_data';
import 'package:rinf/rinf.dart';

Future<void> initializeRust() async {
  await prepareInterface(handleRustSignal);
  startRustLogic();
}

Future<void> finalizeRust() async {
  stopRustLogic();
  await Future.delayed(Duration(milliseconds: 10));
}

final signalHandlers = <int, void Function(Uint8List, Uint8List?)>{
3: (Uint8List messageBytes, Uint8List? blob) {
  final message = mooksviewer.MessageRaw.fromBuffer(messageBytes);
  final rustSignal = RustSignal(
    message,
    blob,
  );
  mooksviewer.messageRawController.add(rustSignal);
},
4: (Uint8List messageBytes, Uint8List? blob) {
  final message = mooksviewer.OutputMessage.fromBuffer(messageBytes);
  final rustSignal = RustSignal(
    message,
    blob,
  );
  mooksviewer.outputMessageController.add(rustSignal);
},
5: (Uint8List messageBytes, Uint8List? blob) {
  final message = mooksviewer.OutputImage.fromBuffer(messageBytes);
  final rustSignal = RustSignal(
    message,
    blob,
  );
  mooksviewer.outputImageController.add(rustSignal);
},
};

void handleRustSignal(int messageId, Uint8List messageBytes, Uint8List? blob) {
  signalHandlers[messageId]!(messageBytes, blob);
}
