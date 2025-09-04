import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xiaotian/xiaotian/model/xiaotian_state.dart';

Widget historyTab(BuildContext context,int index,Map<String,dynamic> tab) {
  return GestureDetector(
    onTap: (){
      //进入对应历史页面
      context.read<xiaotianChatState>().setSessionId(tab['session_id']);
    },
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5)
      ),
      child: Text(tab['title']),
    ),
  );
}

Widget drawerHeader() {
  return Container(
    height: 100, // 控制整体高度
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
    child: const Row(
      children: [
        CircleAvatar(
          radius: 28, // 头像大小
          backgroundImage: AssetImage('assets/avatar.png'),
        ),
        SizedBox(width: 16),
        Text(
          '小天老师',
          style: TextStyle(fontSize: 20, color: Colors.black,fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}


class historyDrawer extends StatefulWidget {
  const historyDrawer({super.key});

  @override
  State<historyDrawer> createState() => _historyDrawerState();
}

class _historyDrawerState extends State<historyDrawer> {
  final List<Map<String,dynamic>> history = [];
  @override
  void initState() {
    //TODO:获取历史记录
    ///dio
    ///history = dio.getHistory
  }
  @override
  Widget build(BuildContext context) {
    context.read<xiaotianChatState>().setHistorySession(history);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          drawerHeader(),
          ...List.generate(context.watch<xiaotianChatState>().historySession.length, (index) =>
              historyTab(context, index,context.watch<xiaotianChatState>().historySession[index])),
        ],
      ),
    );
  }
}

