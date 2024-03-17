// ignore_for_file: invalid_language_version_override

import 'dart:async';
import 'dart:typed_data';
import 'package:rinf/rinf.dart';

//
//  Generated code. Do not modify.
//  source: mooksviewer.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

/// [RINF:DART-SIGNAL]
class InputMessage extends $pb.GeneratedMessage {void sendSignalToRust(Uint8List? blob) {
  sendDartSignal(
    0,
    this.writeToBuffer(),
    blob,
  );
}

  factory InputMessage({
    $core.String? cmd,
    $core.int? intRData,
    $core.int? intGData,
    $core.int? intBData,
    $core.int? intData,
  }) {
    final $result = create();
    if (cmd != null) {
      $result.cmd = cmd;
    }
    if (intRData != null) {
      $result.intRData = intRData;
    }
    if (intGData != null) {
      $result.intGData = intGData;
    }
    if (intBData != null) {
      $result.intBData = intBData;
    }
    if (intData != null) {
      $result.intData = intData;
    }
    return $result;
  }
  InputMessage._() : super();
  factory InputMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InputMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InputMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'mooksviewer'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cmd')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'intRData', $pb.PbFieldType.O3, protoName: 'intRData')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'intGData', $pb.PbFieldType.O3, protoName: 'intGData')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'intBData', $pb.PbFieldType.O3, protoName: 'intBData')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'intData', $pb.PbFieldType.O3, protoName: 'intData')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InputMessage clone() => InputMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InputMessage copyWith(void Function(InputMessage) updates) => super.copyWith((message) => updates(message as InputMessage)) as InputMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InputMessage create() => InputMessage._();
  InputMessage createEmptyInstance() => create();
  static $pb.PbList<InputMessage> createRepeated() => $pb.PbList<InputMessage>();
  @$core.pragma('dart2js:noInline')
  static InputMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InputMessage>(create);
  static InputMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cmd => $_getSZ(0);
  @$pb.TagNumber(1)
  set cmd($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCmd() => $_has(0);
  @$pb.TagNumber(1)
  void clearCmd() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get intRData => $_getIZ(1);
  @$pb.TagNumber(2)
  set intRData($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIntRData() => $_has(1);
  @$pb.TagNumber(2)
  void clearIntRData() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get intGData => $_getIZ(2);
  @$pb.TagNumber(3)
  set intGData($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIntGData() => $_has(2);
  @$pb.TagNumber(3)
  void clearIntGData() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get intBData => $_getIZ(3);
  @$pb.TagNumber(4)
  set intBData($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIntBData() => $_has(3);
  @$pb.TagNumber(4)
  void clearIntBData() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get intData => $_getIZ(4);
  @$pb.TagNumber(5)
  set intData($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIntData() => $_has(4);
  @$pb.TagNumber(5)
  void clearIntData() => clearField(5);
}

/// [RINF:DART-SIGNAL]
class MessageOpenFile extends $pb.GeneratedMessage {void sendSignalToRust(Uint8List? blob) {
  sendDartSignal(
    1,
    this.writeToBuffer(),
    blob,
  );
}

  factory MessageOpenFile({
    $core.String? filepath,
    $core.int? height,
    $core.int? width,
    $core.int? byte,
    $core.int? head,
    $core.int? tail,
  }) {
    final $result = create();
    if (filepath != null) {
      $result.filepath = filepath;
    }
    if (height != null) {
      $result.height = height;
    }
    if (width != null) {
      $result.width = width;
    }
    if (byte != null) {
      $result.byte = byte;
    }
    if (head != null) {
      $result.head = head;
    }
    if (tail != null) {
      $result.tail = tail;
    }
    return $result;
  }
  MessageOpenFile._() : super();
  factory MessageOpenFile.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageOpenFile.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageOpenFile', package: const $pb.PackageName(_omitMessageNames ? '' : 'mooksviewer'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filepath')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'Height', $pb.PbFieldType.OU3, protoName: 'Height')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'Width', $pb.PbFieldType.OU3, protoName: 'Width')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'Byte', $pb.PbFieldType.O3, protoName: 'Byte')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'Head', $pb.PbFieldType.O3, protoName: 'Head')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'Tail', $pb.PbFieldType.O3, protoName: 'Tail')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessageOpenFile clone() => MessageOpenFile()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessageOpenFile copyWith(void Function(MessageOpenFile) updates) => super.copyWith((message) => updates(message as MessageOpenFile)) as MessageOpenFile;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageOpenFile create() => MessageOpenFile._();
  MessageOpenFile createEmptyInstance() => create();
  static $pb.PbList<MessageOpenFile> createRepeated() => $pb.PbList<MessageOpenFile>();
  @$core.pragma('dart2js:noInline')
  static MessageOpenFile getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageOpenFile>(create);
  static MessageOpenFile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filepath => $_getSZ(0);
  @$pb.TagNumber(1)
  set filepath($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFilepath() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilepath() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get height => $_getIZ(1);
  @$pb.TagNumber(2)
  set height($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get width => $_getIZ(2);
  @$pb.TagNumber(3)
  set width($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearWidth() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get byte => $_getIZ(3);
  @$pb.TagNumber(4)
  set byte($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasByte() => $_has(3);
  @$pb.TagNumber(4)
  void clearByte() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get head => $_getIZ(4);
  @$pb.TagNumber(5)
  set head($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHead() => $_has(4);
  @$pb.TagNumber(5)
  void clearHead() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get tail => $_getIZ(5);
  @$pb.TagNumber(6)
  set tail($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTail() => $_has(5);
  @$pb.TagNumber(6)
  void clearTail() => clearField(6);
}

/// [RINF:DART-SIGNAL]
class MessagePlayControl extends $pb.GeneratedMessage {void sendSignalToRust(Uint8List? blob) {
  sendDartSignal(
    2,
    this.writeToBuffer(),
    blob,
  );
}

  factory MessagePlayControl({
    $core.String? cmd,
    $core.double? data,
  }) {
    final $result = create();
    if (cmd != null) {
      $result.cmd = cmd;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  MessagePlayControl._() : super();
  factory MessagePlayControl.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessagePlayControl.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessagePlayControl', package: const $pb.PackageName(_omitMessageNames ? '' : 'mooksviewer'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cmd')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessagePlayControl clone() => MessagePlayControl()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessagePlayControl copyWith(void Function(MessagePlayControl) updates) => super.copyWith((message) => updates(message as MessagePlayControl)) as MessagePlayControl;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessagePlayControl create() => MessagePlayControl._();
  MessagePlayControl createEmptyInstance() => create();
  static $pb.PbList<MessagePlayControl> createRepeated() => $pb.PbList<MessagePlayControl>();
  @$core.pragma('dart2js:noInline')
  static MessagePlayControl getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessagePlayControl>(create);
  static MessagePlayControl? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cmd => $_getSZ(0);
  @$pb.TagNumber(1)
  set cmd($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCmd() => $_has(0);
  @$pb.TagNumber(1)
  void clearCmd() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

/// [RINF:RUST-SIGNAL]
class MessageRaw extends $pb.GeneratedMessage {static Stream<RustSignal<MessageRaw>> rustSignalStream =
    messageRawController.stream.asBroadcastStream();

  factory MessageRaw({
    $core.int? height,
    $core.int? width,
    $core.int? curidx,
    $core.int? endidx,
    $fixnum.Int64? fps,
  }) {
    final $result = create();
    if (height != null) {
      $result.height = height;
    }
    if (width != null) {
      $result.width = width;
    }
    if (curidx != null) {
      $result.curidx = curidx;
    }
    if (endidx != null) {
      $result.endidx = endidx;
    }
    if (fps != null) {
      $result.fps = fps;
    }
    return $result;
  }
  MessageRaw._() : super();
  factory MessageRaw.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageRaw.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageRaw', package: const $pb.PackageName(_omitMessageNames ? '' : 'mooksviewer'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'Height', $pb.PbFieldType.OU3, protoName: 'Height')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'Width', $pb.PbFieldType.OU3, protoName: 'Width')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'curidx', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'endidx', $pb.PbFieldType.O3)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'fps', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessageRaw clone() => MessageRaw()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessageRaw copyWith(void Function(MessageRaw) updates) => super.copyWith((message) => updates(message as MessageRaw)) as MessageRaw;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageRaw create() => MessageRaw._();
  MessageRaw createEmptyInstance() => create();
  static $pb.PbList<MessageRaw> createRepeated() => $pb.PbList<MessageRaw>();
  @$core.pragma('dart2js:noInline')
  static MessageRaw getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageRaw>(create);
  static MessageRaw? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get height => $_getIZ(0);
  @$pb.TagNumber(1)
  set height($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get width => $_getIZ(1);
  @$pb.TagNumber(2)
  set width($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWidth() => $_has(1);
  @$pb.TagNumber(2)
  void clearWidth() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get curidx => $_getIZ(2);
  @$pb.TagNumber(3)
  set curidx($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCuridx() => $_has(2);
  @$pb.TagNumber(3)
  void clearCuridx() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get endidx => $_getIZ(3);
  @$pb.TagNumber(4)
  set endidx($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEndidx() => $_has(3);
  @$pb.TagNumber(4)
  void clearEndidx() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get fps => $_getI64(4);
  @$pb.TagNumber(5)
  set fps($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFps() => $_has(4);
  @$pb.TagNumber(5)
  void clearFps() => clearField(5);
}

/// [RINF:RUST-SIGNAL]
class OutputMessage extends $pb.GeneratedMessage {static Stream<RustSignal<OutputMessage>> rustSignalStream =
    outputMessageController.stream.asBroadcastStream();

  factory OutputMessage({
    $core.int? currentNumber,
    $core.int? data,
  }) {
    final $result = create();
    if (currentNumber != null) {
      $result.currentNumber = currentNumber;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  OutputMessage._() : super();
  factory OutputMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OutputMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OutputMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'mooksviewer'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'currentNumber', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'Data', $pb.PbFieldType.OU3, protoName: 'Data')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OutputMessage clone() => OutputMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OutputMessage copyWith(void Function(OutputMessage) updates) => super.copyWith((message) => updates(message as OutputMessage)) as OutputMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OutputMessage create() => OutputMessage._();
  OutputMessage createEmptyInstance() => create();
  static $pb.PbList<OutputMessage> createRepeated() => $pb.PbList<OutputMessage>();
  @$core.pragma('dart2js:noInline')
  static OutputMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OutputMessage>(create);
  static OutputMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get currentNumber => $_getIZ(0);
  @$pb.TagNumber(1)
  set currentNumber($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCurrentNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearCurrentNumber() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get data => $_getIZ(1);
  @$pb.TagNumber(2)
  set data($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

/// [RINF:RUST-SIGNAL]
class OutputImage extends $pb.GeneratedMessage {static Stream<RustSignal<OutputImage>> rustSignalStream =
    outputImageController.stream.asBroadcastStream();

  factory OutputImage({
    $core.int? data,
    $core.int? rdata,
    $core.int? gdata,
    $core.int? bdata,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    if (rdata != null) {
      $result.rdata = rdata;
    }
    if (gdata != null) {
      $result.gdata = gdata;
    }
    if (bdata != null) {
      $result.bdata = bdata;
    }
    return $result;
  }
  OutputImage._() : super();
  factory OutputImage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OutputImage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OutputImage', package: const $pb.PackageName(_omitMessageNames ? '' : 'mooksviewer'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'rdata', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'gdata', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'bdata', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OutputImage clone() => OutputImage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OutputImage copyWith(void Function(OutputImage) updates) => super.copyWith((message) => updates(message as OutputImage)) as OutputImage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OutputImage create() => OutputImage._();
  OutputImage createEmptyInstance() => create();
  static $pb.PbList<OutputImage> createRepeated() => $pb.PbList<OutputImage>();
  @$core.pragma('dart2js:noInline')
  static OutputImage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OutputImage>(create);
  static OutputImage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get data => $_getIZ(0);
  @$pb.TagNumber(1)
  set data($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get rdata => $_getIZ(1);
  @$pb.TagNumber(2)
  set rdata($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRdata() => $_has(1);
  @$pb.TagNumber(2)
  void clearRdata() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get gdata => $_getIZ(2);
  @$pb.TagNumber(3)
  set gdata($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasGdata() => $_has(2);
  @$pb.TagNumber(3)
  void clearGdata() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get bdata => $_getIZ(3);
  @$pb.TagNumber(4)
  set bdata($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBdata() => $_has(3);
  @$pb.TagNumber(4)
  void clearBdata() => clearField(4);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');

final messageRawController = StreamController<RustSignal<MessageRaw>>();

final outputMessageController = StreamController<RustSignal<OutputMessage>>();

final outputImageController = StreamController<RustSignal<OutputImage>>();
