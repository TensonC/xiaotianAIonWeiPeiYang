import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

/// ================ 模型 =================
class ChatEvent {
  final String type; // token / source / followup / trace_id / error
  final dynamic data;
  ChatEvent._(this.type, this.data);

  factory ChatEvent.token(String text) => ChatEvent._('token', {'token': text});
  factory ChatEvent.source(List<Source> list) => ChatEvent._('source', list);
  factory ChatEvent.followup(String question) =>
      ChatEvent._('followup', {'question': question});
  factory ChatEvent.traceId(String id) =>
      ChatEvent._('trace_id', {'trace_id': id});
  factory ChatEvent.error(String msg) => ChatEvent._('error', {'message': msg});

  @override
  String toString() => 'ChatEvent($type,$data)';
}

class Source {
  final String title, link, pubTime, contentType;
  Source.fromJson(Map<String, dynamic> m)
      : title = m['title'] ?? '',
        link = m['link'] ?? '',
        pubTime = m['publication_time'] ?? '',
        contentType = m['content_type'] ?? '';
}

class HistorySession {
  final String sessionId, title, creationTime;
  HistorySession.fromJson(Map<String, dynamic> m)
      : sessionId = m['session_id'],
        title = m['title'],
        creationTime = m['creation_time'];

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'title': title,
        'creation_time': creationTime,
      };
}

class ChatMessage {
  final String role, content;
  final bool file;
  final int likeCount;
  final String? traceId;
  ChatMessage.fromJson(Map<String, dynamic> m)
      : role = m['role'],
        content = m['content'],
        file = m['file'] == true,
        likeCount = int.tryParse(m['likeCount']?.toString() ?? '0') ?? 0,
        traceId = m['trace_id'];
  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'file': file,
        'likeCount': likeCount,
        'traceId': traceId
      };
}

/// ================ API 单例 =================
class AiTjuApi {
  AiTjuApi._();
  static final _instance = AiTjuApi._();
  factory AiTjuApi() => _instance;

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://student.tju.edu.cn/ai', // 保持与现有地址一致
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 120),
    ),
  )..interceptors.addAll([
      InterceptorsWrapper(onRequest: (opt, handler) {
        opt.headers.putIfAbsent('Accept', () => 'text/event-stream');
        return handler.next(opt);
      }),
    ]);

  /// Cho phép cập nhật header mặc định (Cookie/Authorization...) nếu muốn
  void updateDefaultHeaders(Map<String, String> headers) {
    dio.options.headers.addAll(headers);
  }

  /* ============== 1. SSE 流式对话 ============== */
  /// Trả về Stream<ChatEvent> để render realtime
  Stream<ChatEvent> streamChat({
    required String prompt,
    required String sessionId,
    required String userId,
    List<String>? files,
    String? searchTime,
    String? searchType,
    Map<String, String>? headers, // header
  }) async* {
    final params = <String, dynamic>{
      'prompt': prompt,
      'sessionId': sessionId,
      'userId': userId,
      if (files != null) 'files': files,
      if (searchTime != null) 'searchTime': searchTime,
      if (searchType != null) 'searchType': searchType,
    };

    final rs = await dio.get(
      '/ai-api/ai/stream',
      queryParameters: params,
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
      ),
    );

    // stream bytes -> utf8 ->  SSE

    final lines = rs.data.stream
        .cast<List<int>>() // Stream<Uint8List> -> Stream<List<int>>
        .transform(utf8.decoder) // -> Stream<String>
        .transform(const LineSplitter()); // -> Stream<String> each lines

    final eventData = StringBuffer();

    await for (final line in lines) {
      if (line.isEmpty) {
        final dataStr = eventData.toString();
        eventData.clear();
        if (dataStr.isEmpty) continue;
        if (dataStr == '[DONE]') break;
        try {
          final map = jsonDecode(dataStr);
          if (map['token'] != null) yield ChatEvent.token(map['token']);
          if (map['source'] != null) {
            final list = (map['source'] as List)
                .map((e) => Source.fromJson(e as Map<String, dynamic>))
                .toList();
            yield ChatEvent.source(list);
          }
          if (map['followup'] != null) {
            yield ChatEvent.followup(map['followup'].toString());
          }
          if (map['trace_id'] != null) {
            yield ChatEvent.traceId(map['trace_id'].toString());
          }
          if (map['error'] != null) {
            yield ChatEvent.error(map['error'].toString());
          }
        } catch (_) {}
        continue;
      }

      if (line.startsWith('data:')) {
        final payload = line.length >= 5 ? line.substring(5).trimLeft() : '';
        if (payload.isNotEmpty) {
          if (eventData.isNotEmpty) eventData.write('\n');
          eventData.write(payload);
        }
      } else {
        print('不是data');
      }
    }
  }

  /// ============== 1b. Fetch full Answer 链接token==============
  /// Return fullText (token) + rawSse (所有 SSE ）
  Future<({String fullText, String rawSse})> fetchFullAnswer({
    required String prompt,
    required String sessionId,
    required String userId,
    List<String>? files,
    String? searchTime,
    String? searchType,
    Map<String, String>? headers,
  }) async {
    final params = <String, dynamic>{
      'prompt': prompt,
      'sessionId': sessionId,
      'userId': userId,
      if (files != null) 'files': files,
      if (searchTime != null) 'searchTime': searchTime,
      if (searchType != null) 'searchType': searchType,
    };

    final rs = await dio.get(
      '/ai-api/ai/stream',
      queryParameters: params,
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
      ),
    );

    final stringStream = utf8.decoder.bind(rs.data.stream.cast<List<int>>());
    final lines = const LineSplitter().bind(stringStream);

    final full = StringBuffer();
    final raw = StringBuffer();
    final eventData = StringBuffer();

    await for (final line in lines) {
      raw.writeln(line);

      if (line.isEmpty) {
        final dataStr = eventData.toString();
        eventData.clear();
        if (dataStr.isEmpty) continue;
        if (dataStr == '[DONE]') break;
        try {
          final map = jsonDecode(dataStr);
          final token = map['token'];
          if (token is String) full.write(token);
        } catch (_) {}
        continue;
      }

      if (line.startsWith('data:')) {
        final payload = line.length >= 5 ? line.substring(5).trimLeft() : '';
        if (payload.isNotEmpty) {
          if (eventData.isNotEmpty) eventData.write('\n');
          eventData.write(payload);
        }
      }
    }

    return (fullText: full.toString(), rawSse: raw.toString());
  }

  /* ============== 2. 历史会话列表 ============== */
  Future<List<HistorySession>> getAllSessions(String userId) async {
    final rs = await dio.get('/ai-api/ai/get_all_sessions/$userId');
    final list = (jsonDecode(rs.data['msg']) as List)
        .map((e) => HistorySession.fromJson(e))
        .toList();
    return list;
  }

  /* ============== 3. 单会话详情 ============== */
  Future<List<ChatMessage>> getConversation({
    required String sessionId,
    required String userId,
  }) async {
    final rs = await dio.get(
      '/ai-api/ai/get_conversation',
      queryParameters: {'sessionId': sessionId, 'userId': userId},
    );
    final list = (jsonDecode(rs.data['msg']) as List)
        .map((e) => ChatMessage.fromJson(e))
        .toList();
    return list;
  }
}
