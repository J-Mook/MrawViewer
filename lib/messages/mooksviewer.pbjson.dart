//
//  Generated code. Do not modify.
//  source: mooksviewer.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use inputMessageDescriptor instead')
const InputMessage$json = {
  '1': 'InputMessage',
  '2': [
    {'1': 'cmd', '3': 1, '4': 1, '5': 9, '10': 'cmd'},
    {'1': 'intRData', '3': 2, '4': 1, '5': 5, '10': 'intRData'},
    {'1': 'intGData', '3': 3, '4': 1, '5': 5, '10': 'intGData'},
    {'1': 'intBData', '3': 4, '4': 1, '5': 5, '10': 'intBData'},
    {'1': 'intData', '3': 5, '4': 1, '5': 5, '10': 'intData'},
  ],
};

/// Descriptor for `InputMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inputMessageDescriptor = $convert.base64Decode(
    'CgxJbnB1dE1lc3NhZ2USEAoDY21kGAEgASgJUgNjbWQSGgoIaW50UkRhdGEYAiABKAVSCGludF'
    'JEYXRhEhoKCGludEdEYXRhGAMgASgFUghpbnRHRGF0YRIaCghpbnRCRGF0YRgEIAEoBVIIaW50'
    'QkRhdGESGAoHaW50RGF0YRgFIAEoBVIHaW50RGF0YQ==');

@$core.Deprecated('Use messageOpenFileDescriptor instead')
const MessageOpenFile$json = {
  '1': 'MessageOpenFile',
  '2': [
    {'1': 'filepath', '3': 1, '4': 1, '5': 9, '10': 'filepath'},
    {'1': 'Height', '3': 2, '4': 1, '5': 13, '10': 'Height'},
    {'1': 'Width', '3': 3, '4': 1, '5': 13, '10': 'Width'},
    {'1': 'Byte', '3': 4, '4': 1, '5': 5, '10': 'Byte'},
    {'1': 'Head', '3': 5, '4': 1, '5': 5, '10': 'Head'},
    {'1': 'Tail', '3': 6, '4': 1, '5': 5, '10': 'Tail'},
  ],
};

/// Descriptor for `MessageOpenFile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageOpenFileDescriptor = $convert.base64Decode(
    'Cg9NZXNzYWdlT3BlbkZpbGUSGgoIZmlsZXBhdGgYASABKAlSCGZpbGVwYXRoEhYKBkhlaWdodB'
    'gCIAEoDVIGSGVpZ2h0EhQKBVdpZHRoGAMgASgNUgVXaWR0aBISCgRCeXRlGAQgASgFUgRCeXRl'
    'EhIKBEhlYWQYBSABKAVSBEhlYWQSEgoEVGFpbBgGIAEoBVIEVGFpbA==');

@$core.Deprecated('Use messagePlayControlDescriptor instead')
const MessagePlayControl$json = {
  '1': 'MessagePlayControl',
  '2': [
    {'1': 'cmd', '3': 1, '4': 1, '5': 9, '10': 'cmd'},
    {'1': 'data', '3': 2, '4': 1, '5': 1, '10': 'data'},
  ],
};

/// Descriptor for `MessagePlayControl`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messagePlayControlDescriptor = $convert.base64Decode(
    'ChJNZXNzYWdlUGxheUNvbnRyb2wSEAoDY21kGAEgASgJUgNjbWQSEgoEZGF0YRgCIAEoAVIEZG'
    'F0YQ==');

@$core.Deprecated('Use messageRawDescriptor instead')
const MessageRaw$json = {
  '1': 'MessageRaw',
  '2': [
    {'1': 'Height', '3': 1, '4': 1, '5': 13, '10': 'Height'},
    {'1': 'Width', '3': 2, '4': 1, '5': 13, '10': 'Width'},
    {'1': 'curidx', '3': 3, '4': 1, '5': 5, '10': 'curidx'},
    {'1': 'endidx', '3': 4, '4': 1, '5': 5, '10': 'endidx'},
    {'1': 'fps', '3': 5, '4': 1, '5': 4, '10': 'fps'},
  ],
};

/// Descriptor for `MessageRaw`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageRawDescriptor = $convert.base64Decode(
    'CgpNZXNzYWdlUmF3EhYKBkhlaWdodBgBIAEoDVIGSGVpZ2h0EhQKBVdpZHRoGAIgASgNUgVXaW'
    'R0aBIWCgZjdXJpZHgYAyABKAVSBmN1cmlkeBIWCgZlbmRpZHgYBCABKAVSBmVuZGlkeBIQCgNm'
    'cHMYBSABKARSA2Zwcw==');

@$core.Deprecated('Use outputMessageDescriptor instead')
const OutputMessage$json = {
  '1': 'OutputMessage',
  '2': [
    {'1': 'current_number', '3': 1, '4': 1, '5': 5, '10': 'currentNumber'},
    {'1': 'Data', '3': 2, '4': 1, '5': 13, '10': 'Data'},
  ],
};

/// Descriptor for `OutputMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outputMessageDescriptor = $convert.base64Decode(
    'Cg1PdXRwdXRNZXNzYWdlEiUKDmN1cnJlbnRfbnVtYmVyGAEgASgFUg1jdXJyZW50TnVtYmVyEh'
    'IKBERhdGEYAiABKA1SBERhdGE=');

@$core.Deprecated('Use outputImageDescriptor instead')
const OutputImage$json = {
  '1': 'OutputImage',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 5, '10': 'data'},
    {'1': 'rdata', '3': 2, '4': 1, '5': 5, '10': 'rdata'},
    {'1': 'gdata', '3': 3, '4': 1, '5': 5, '10': 'gdata'},
    {'1': 'bdata', '3': 4, '4': 1, '5': 5, '10': 'bdata'},
  ],
};

/// Descriptor for `OutputImage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outputImageDescriptor = $convert.base64Decode(
    'CgtPdXRwdXRJbWFnZRISCgRkYXRhGAEgASgFUgRkYXRhEhQKBXJkYXRhGAIgASgFUgVyZGF0YR'
    'IUCgVnZGF0YRgDIAEoBVIFZ2RhdGESFAoFYmRhdGEYBCABKAVSBWJkYXRh');

