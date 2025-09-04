import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';

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
        likeCount = int.tryParse(m['likeCount'] ?? '0') ?? 0,
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

  final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://student.tju.edu.cn/ai', // 换成真实域名
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 120),
  ))
    ..interceptors.addAll([
      // PrettyDioLogger(requestBody: true, responseBody: false),
      InterceptorsWrapper(onRequest: (opt, handler) {
        // 统一加 token 可在这里
        return handler.next(opt);
      }),
    ]);

  /* ============== 1. SSE 流式对话 ============== */
  /// 返回 Stream<ChatEvent>，调用方 listen 即可逐字渲染
  Stream<ChatEvent> streamChat({
    required String prompt,
    required String sessionId,
    required String userId,
    List<String>? files,
    String? searchTime,
    String? searchType,
  }) async* {
    final form = FormData.fromMap({
      'prompt': prompt,
      'sessionId': sessionId,
      'userId': userId,
      if (files != null) 'files': files,
      if (searchTime != null) 'searchTime': searchTime,
      if (searchType != null) 'searchType': searchType,
    });

    // Dio 流式响应
    final rs = await dio.get(
      // ← 注意用 post
      '/ai-api/ai/stream',
      data: form, // 整个 FormData 当 body
      options: Options(responseType: ResponseType.stream),
    );

    // await for (final chunk in rs.data.stream) {
    //   final lines = utf8.decode(chunk).split('\n');
    //   for (final line in lines) {
    //     if (line.startsWith('data: ')) {
    //       final raw = line.substring(6);
    //       if (raw == '[DONE]') continue;
    //       final map = jsonDecode(raw);
    //       if (map['token'] != null) yield ChatEvent.token(map['token']);
    //       if (map['source'] != null) {
    //         yield ChatEvent.source((map['source'] as List)
    //             .map((e) => Source.fromJson(e))
    //             .toList());
    //       }
    //       if (map['followup'] != null)
    //         yield ChatEvent.followup(map['followup']);
    //       if (map['trace_id'] != null) yield ChatEvent.traceId(map['trace_id']);
    //       if (map['error'] != null) yield ChatEvent.error(map['error']);
    //     }
    //   }
    // }
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
    final rs = await dio.get('/ai-api/ai/get_conversation',
        queryParameters: {'sessionId': sessionId, 'userId': userId});
    final list = (jsonDecode(rs.data['msg']) as List)
        .map((e) => ChatMessage.fromJson(e))
        .toList();
    return list;
  }
}
