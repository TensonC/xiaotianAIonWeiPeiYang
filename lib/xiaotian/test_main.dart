// 这个文档用来测试能不能获取到信息

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:xiaotian/xiaotian/model/xiaotian_dio.dart';

Future<void> main() async {
  final api = AiTjuApi();

  //这里只是暂时的数据

  api.updateDefaultHeaders({
    'Content-Type': 'application/x-www-form-urlencoded',
    'Cookie':
        'Hm_lvt_0eac3f7954950aa62e0d5e0919956fec=1729842439; JSESSIONID=1Ni+ftKcFxQn/yzm5MPvKyWyOzjdJHej/6PVbgf0I6c=; Admin-Token=eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6ImYxMGM3YjRmLTYzMmYtNDY5ZC1iN2E0LTU2MzNlZGI1NGJiZCJ9.rDeZ1sxXSVfmy4PmRk7oAo8Yt2svQglLzNjfHMhLc_Z8uWa1VvMcUvAIcqzBGtVyxjwp5FJUr5EM02oIhJqWbA; sidebarStatus=0',
    'Authorization':
        'Bearer eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6ImYxMGM3YjRmLTYzMmYtNDY5ZC1iN2E0LTU2MzNlZGI1NGJiZCJ9.rDeZ1sxXSVfmy4PmRk7oAo8Yt2svQglLzNjfHMhLc_Z8uWa1VvMcUvAIcqzBGtVyxjwp5FJUr5EM02oIhJqWbA',
  });
  final userId = "6323000439";
  final prompt = "你是谁？";
  final buffer = StringBuffer();

  // Example: test history chat
  // final sessions = await api.getAllSessions(userId);
  // for (var session in sessions) {
  //   print("Session: ${session.sessionId} - Title: ${session.title}");
  // }

  // Example: test chat stream

  final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

  final result = await api.fetchFullAnswer(
    prompt: prompt,
    sessionId: sessionId,
    userId: userId,
    searchType: 'precise',
    searchTime: 'noLimit',
  );
  print('--- RAW SSE ---\n${result.rawSse}');
  print('--- FULL ANSWER ---\n${result.fullText}');

  final sb = StringBuffer();
  await for (final evt in api.streamChat(
    prompt: prompt,
    sessionId: sessionId,
    userId: userId,
    searchType: 'precise',
    searchTime: 'noLimit',
  )) {
    if (evt.type == 'token') {
      sb.write(evt.data['token']);
    }
  }
  print('--- STREAMED FULL ANSWER ---\n$sb');
}
//   print(params);

//   print(rs.requestOptions.uri);
//   await for (final chunk in rs.data.stream) {
//     final text = utf8.decode(chunk);
//     print('Raw chunk: $text');
//     buffer.write(text);

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
