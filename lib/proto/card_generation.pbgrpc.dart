// Generated code. Do not modify.
// source: card_generation.proto

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'card_generation.pb.dart' as $0;

export 'card_generation.pb.dart';

@$pb.ProtoName('sigma.CardGenerationService')
class CardGenerationServiceClient extends $grpc.Client {
  static final _$generateCards =
      $grpc.ClientMethod<$0.GenerateCardsRequest, $0.CardChunk>(
    '/sigma.CardGenerationService/GenerateCards',
    ($0.GenerateCardsRequest value) => value.writeToBuffer(),
    ($core.List<$core.int> value) => $0.CardChunk.fromBuffer(value),
  );

  CardGenerationServiceClient(
    $grpc.ClientChannel channel, {
    $grpc.CallOptions? options,
    $core.Iterable<$grpc.ClientInterceptor>? interceptors,
  }) : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseStream<$0.CardChunk> generateCards(
    $0.GenerateCardsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
      _$generateCards,
      $async.Stream.value(request),
      options: options,
    );
  }
}
