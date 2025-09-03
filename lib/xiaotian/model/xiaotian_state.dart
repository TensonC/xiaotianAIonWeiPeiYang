

import 'package:flutter/cupertino.dart';

class xiaotianInputState {

  String prompt;        //用户输入内容
  String sessionId;     //会话id
  String userId;        //用户id
  List<String> files;   //文件url
  String searchTime;    //搜索时间范围
  String searchType;    //搜索类型


  xiaotianInputState(this.prompt,this.sessionId,this.userId,this.files,this.searchTime,this.searchType);

}

class xiaotianChatState extends ChangeNotifier {

  static final xiaotianChatState _instance = xiaotianChatState._internal();
  factory xiaotianChatState()=>_instance;
  xiaotianChatState._internal();

  //该会话下的聊天内容
  List<Map<String,dynamic>> _messages = [
    {"role":"user","file":false,"content":"你好"},
    {"trace_id":"b5e9503b2c27755c0bcb99722d330dd2",
      "role":"ai",
      "likeCount":"0",
      "source":[
        {"title":"天津大学本科生选修课程管理办法","content_type":"database"},
        {"title":"微北洋校务专区问答","content_type":"database"}
      ],
      "content":"同学你好！我是AI辅导员\u2014\u2014小天老师，可以根据我掌握的天津大学相关情况，为你解答问题！😊"
    },
    {"role":"user","file":false,"content":"0.8和0.11哪个大"},
    {"trace_id":"ec4b975d5b554fc4b4e77878fdf05771","role":"ai","likeCount":"0","content":"同学你好！比较两个数的大小时，我们可以直接对比它们的数值：\n\n- 0.8 表示的是十分之八；\n- 0.11 表示的是百分之十一。\n\n从数值上看，0.8 > 0.11。 \n\n因此，0.8 比 0.11 大哦～😊\n\n如果你有更多数学问题，欢迎继续提问！"}
  ];
  List<Map<String,dynamic>> get messages => _messages;

  void messageGet(List<Map<String,dynamic>> message) {
    _messages = message;
    notifyListeners();
  }

  void messageAdd(Map<String,dynamic> mes) {
    _messages.add(mes);
    notifyListeners();
  }

  //用户id
  String _userId = '0';
  String get userId => _userId;
  void setUserId(String id) {
    _userId = id;
  }

  //会话id
  String _sessionId = '0';
  String get sessionId => _sessionId;
  void setSessionId(String id) {
    _sessionId = id;
  }

}
