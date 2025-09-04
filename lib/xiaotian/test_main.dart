// 这个文档用来测试能不能获取到信息

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:xiaotian/xiaotian/model/xiaotian_dio.dart';

void main() async {
  final api = AiTjuApi();
  final userId = "6323000439";
  final prompt = "你是谁？";
  final buffer = StringBuffer();

  // Example: test history chat
  // final sessions = await api.getAllSessions(userId);
  // for (var session in sessions) {
  //   print("Session: ${session.sessionId} - Title: ${session.title}");
  // }

  // Example: test chat stream
  try {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final params = {
      'prompt': prompt,
      'sessionId': sessionId,
      'userId': userId,
      'searchType': 'precise',
      'searchTime': 'noLimit',
    };
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie':
          'Hm_lvt_0eac3f7954950aa62e0d5e0919956fec=1729842439; JSESSIONID=1Ni+ftKcFxQn/yzm5MPvKyWyOzjdJHej/6PVbgf0I6c=; Admin-Token=eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6ImYxMGM3YjRmLTYzMmYtNDY5ZC1iN2E0LTU2MzNlZGI1NGJiZCJ9.rDeZ1sxXSVfmy4PmRk7oAo8Yt2svQglLzNjfHMhLc_Z8uWa1VvMcUvAIcqzBGtVyxjwp5FJUr5EM02oIhJqWbA; sidebarStatus=0',
      'Authorization':
          'Bearer eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6ImYxMGM3YjRmLTYzMmYtNDY5ZC1iN2E0LTU2MzNlZGI1NGJiZCJ9.rDeZ1sxXSVfmy4PmRk7oAo8Yt2svQglLzNjfHMhLc_Z8uWa1VvMcUvAIcqzBGtVyxjwp5FJUr5EM02oIhJqWbA',
    };
    print(params);
    final rs = await api.dio.get(
      '/ai-api/ai/stream',
      queryParameters: params,
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
      ),
    );
    print(rs.requestOptions.uri);
    await for (final chunk in rs.data.stream) {
      final text = utf8.decode(chunk);
      print('Raw chunk: $text');
      buffer.write(text);
      //TODO: Decode json response 这部分正在找解决response decode之后不全的问题

      // final lines = text.split('\n');
      // for (final line in lines) {
      //   if (line.startsWith('data:')) {
      //     final raw = line.substring(5).trim();
      //     if (raw.isEmpty || raw == '[DONE]') continue;
      //     try {
      //       final map = jsonDecode(raw);
      //       if (map['token'] != null) {
      //         buffer.write(map['token']);
      //       }
      //     } catch (e) {
      //       print('Decode Error: $e');
      //     }
      //   }
      // }
    }

    print('Full response :');
    print(buffer.toString());
    // await for (final event in api.streamChat(
    //   prompt: prompt,
    //   sessionId: sessionId,
    //   userId: userId,
    //   searchType: 'precise',
    //   searchTime: 'noLimit',
    //   headers: headers,
    // )) {
    //   if (event.type == 'token') {
    //     buffer.write(event.data['token']);
    //   }
    // }

    // print("Văn bản đầy đủ AI trả lời:");
    // print(buffer.toString());
  } catch (e, st) {
    print("Stream chat error: $e");
    print(st);
  }

  // getConservation
  // try {
  //   final sessions = await api.getAllSessions(userId);
  //   if (sessions.isEmpty) {
  //     print("Empty");
  //   } else {
  //     for (var session in sessions) {
  //       print(
  //           "Session: ${session.sessionId} - Title: ${session.title} - Time: ${session.creationTime}");
  //     }
  //   }
  // } catch (e, st) {
  //   print("Error: $e");
  //   print(st);
  // }
}
