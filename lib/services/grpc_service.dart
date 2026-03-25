import 'package:grpc/grpc.dart';
import '../proto/card_generation.pbgrpc.dart';

class GrpcService {
  static const String _host = 'localhost';
  static const int _port = 50051;

  static ClientChannel? _channel;
  static CardGenerationServiceClient? _client;

  static CardGenerationServiceClient get client {
    _channel ??= ClientChannel(
      _host,
      port: _port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        connectionTimeout: Duration(seconds: 10),
      ),
    );
    _client ??= CardGenerationServiceClient(_channel!);
    return _client!;
  }

  static Future<void> shutdown() async {
    await _channel?.shutdown();
    _channel = null;
    _client = null;
  }

  /// Stream card chunks from the generation service.
  /// Yields [CardChunk] until [CardChunk.done] is true or stream ends.
  static Stream<CardChunk> generateCards({
    required String text,
    required String deckId,
    int targetCount = 10,
  }) {
    final request = GenerateCardsRequest(
      text: text,
      deckId: deckId,
      targetCount: targetCount,
    );
    return client.generateCards(request);
  }
}
