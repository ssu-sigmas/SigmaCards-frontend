// Generated code. Do not modify.
// source: card_generation.proto

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class GenerateCardsRequest extends $pb.GeneratedMessage {
  factory GenerateCardsRequest({
    $core.String? text,
    $core.int? targetCount,
    $core.String? deckId,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (targetCount != null) result.targetCount = targetCount;
    if (deckId != null) result.deckId = deckId;
    return result;
  }

  GenerateCardsRequest._() : super();

  factory GenerateCardsRequest.fromBuffer(
    $core.List<$core.int> i, [
    $pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY,
  ]) =>
      create()..mergeFromBuffer(i, r);

  factory GenerateCardsRequest.fromJson(
    $core.String i, [
    $pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY,
  ]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'GenerateCardsRequest',
    package: const $pb.PackageName('sigma'),
    createEmptyInstance: create,
  )
    ..aOS(1, 'text')
    ..a<$core.int>(2, 'targetCount', $pb.PbFieldType.O3)
    ..aOS(3, 'deckId')
    ..hasRequiredFields = false;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateCardsRequest create() => GenerateCardsRequest._();

  @$core.override
  GenerateCardsRequest createEmptyInstance() => create();

  static $pb.PbList<GenerateCardsRequest> createRepeated() =>
      $pb.PbList<GenerateCardsRequest>();

  @$core.pragma('dart2js:noInline')
  static GenerateCardsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateCardsRequest>(create);
  static GenerateCardsRequest? _defaultInstance;

  $core.String get text => $_getSZ(0);
  set text($core.String v) {
    $_setString(0, v);
  }

  $core.bool hasText() => $_has(0);
  void clearText() => clearField(1);

  $core.int get targetCount => $_getIZ(1);
  set targetCount($core.int v) {
    $_setSignedInt32(1, v);
  }

  $core.bool hasTargetCount() => $_has(1);
  void clearTargetCount() => clearField(2);

  $core.String get deckId => $_getSZ(2);
  set deckId($core.String v) {
    $_setString(2, v);
  }

  $core.bool hasDeckId() => $_has(2);
  void clearDeckId() => clearField(3);
}

class CardChunk extends $pb.GeneratedMessage {
  factory CardChunk({
    $core.String? front,
    $core.String? back,
    $core.bool? done,
    $core.String? error,
  }) {
    final result = create();
    if (front != null) result.front = front;
    if (back != null) result.back = back;
    if (done != null) result.done = done;
    if (error != null) result.error = error;
    return result;
  }

  CardChunk._() : super();

  factory CardChunk.fromBuffer(
    $core.List<$core.int> i, [
    $pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY,
  ]) =>
      create()..mergeFromBuffer(i, r);

  factory CardChunk.fromJson(
    $core.String i, [
    $pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY,
  ]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'CardChunk',
    package: const $pb.PackageName('sigma'),
    createEmptyInstance: create,
  )
    ..aOS(1, 'front')
    ..aOS(2, 'back')
    ..aOB(3, 'done')
    ..aOS(4, 'error')
    ..hasRequiredFields = false;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CardChunk create() => CardChunk._();

  @$core.override
  CardChunk createEmptyInstance() => create();

  static $pb.PbList<CardChunk> createRepeated() => $pb.PbList<CardChunk>();

  @$core.pragma('dart2js:noInline')
  static CardChunk getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CardChunk>(create);
  static CardChunk? _defaultInstance;

  $core.String get front => $_getSZ(0);
  set front($core.String v) {
    $_setString(0, v);
  }

  $core.bool hasFront() => $_has(0);
  void clearFront() => clearField(1);

  $core.String get back => $_getSZ(1);
  set back($core.String v) {
    $_setString(1, v);
  }

  $core.bool hasBack() => $_has(1);
  void clearBack() => clearField(2);

  $core.bool get done => $_getBF(2);
  set done($core.bool v) {
    $_setBool(2, v);
  }

  $core.bool hasDone() => $_has(2);
  void clearDone() => clearField(3);

  $core.String get error => $_getSZ(3);
  set error($core.String v) {
    $_setString(3, v);
  }

  $core.bool hasError() => $_has(3);
  void clearError() => clearField(4);
}
