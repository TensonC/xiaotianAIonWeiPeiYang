import 'package:flutter/material.dart';


class xiaotianInputState extends ChangeNotifier {
  List<String> files = [];        //文件url
  String searchTime = 'onLimit';         //搜索时间范围
  String searchType = 'precise';         //搜索类型
  FocusNode node = FocusNode();
  TextEditingController textController = TextEditingController();

  xiaotianInputState();

  //发送完之后清除输入状态
  void clear() {
    files = [];
    searchType = 'precise';
    searchTime = 'onLimit';
    node.unfocus();
    textController.clear();
    notifyListeners();
  }

  //让焦点失焦
  void unfocus() {
    node.unfocus();
  }

  //返回一个message
  Map<String,dynamic> makeMessage() {
      return {
        'role':'user',
        'files':files,
        'content':textController.text.trim()
      };
  }

  //重新编辑
  void onEdit(String content) {
    textController.text = content;
    node.requestFocus();
  }



}

class xiaotianChatState extends ChangeNotifier {

  static final xiaotianChatState _instance = xiaotianChatState._internal();
  factory xiaotianChatState()=>_instance;
  xiaotianChatState._internal();

  final Map<String, List<Map<String, dynamic>>> _sessions = {

  };
  List<Map<String,dynamic>> _historySession = [];
  String _sessionId = '0';
  String _userId = '0';

  // 获取当前会话消息
  List<Map<String, dynamic>> get messages => _sessions[_sessionId] ?? [];

  //获得搜索历史
  List<Map<String, dynamic>> get historySession => _historySession;

  // 获取当前 sessionId
  String get sessionId => _sessionId;

  //获取历史会话记录
  void setHistorySession(List<Map<String, dynamic>> history) {
    _historySession = history;
    notifyListeners();
  }

  //点击新会话后将会话id变成0，并通知,只有在第一次发消息的时候才申请会话id并申请会话
  void openNewSession() {
    _sessionId = '0';
    notifyListeners();
  }

  // 切换会话
  void setSessionId(String id) {
    _sessionId = id;
    _sessions.putIfAbsent(id, () => []); // 如果会话不存在则创建
    notifyListeners();
  }

  // 往当前会话中添加消息
  void messageAdd(Map<String, dynamic> mes) {
    _sessions.putIfAbsent(_sessionId, () => []);
    _sessions[_sessionId]!.add(mes);
    notifyListeners();
  }

  // 覆盖当前会话的消息（用于从后端拉取历史）
  void messageSet(List<Map<String, dynamic>> messages) {
    _sessions[_sessionId] = messages;
    notifyListeners();
  }

  // 用户ID管理
  String get userId => _userId;
  void setUserId(String id) {
    _userId = id;
    notifyListeners();
  }

}
