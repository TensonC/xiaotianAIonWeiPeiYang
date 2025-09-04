import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/xiaotian_state.dart';
import '../../model/xiaotian_dio.dart';
import 'dart:convert';

class historyTab extends StatelessWidget {
  const historyTab({super.key,required this.tab});
  final Map<String,dynamic> tab;

  Future<void> _loadHistory() async {
    final sessions = await AiTjuApi().getAllSessions('3024004065');
    final list = sessions.map((e) => e.toJson()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        //拿到Provider
        final chatState = context.read<xiaotianChatState>();
        //关闭抽屉
        Navigator.of(context).pop();
        //获取消息
        final mes = await AiTjuApi().getConversation(
          sessionId: tab['session_id'],
          userId: '3024004065',
        );
        final mesList = mes.map((e) => e.toJson()).toList();
        //重新加载历史栏
        final sessions = await AiTjuApi().getAllSessions('3024004065');
        final list = sessions.map((e) => e.toJson()).toList();
        //写入消息
        chatState
          ..setSessionId(tab['session_id'])
          ..messageSet(mesList)
          ..setHistorySession(list);

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
}



Widget drawerHeader() {
  return Container(
    height: 100, // 控制整体高度
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
    child: const Row(
      children: [
        // CircleAvatar(
        //   radius: 28, // 头像大小
        //   backgroundImage: AssetImage('assets/avatar.png'),
        // ),
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

  @override
  void initState() {
    super.initState();
    ///加载history改成从保存的history中获取
    // _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<xiaotianChatState>().historySession;

    // 先排序
    final sortedHistory = [...history]..sort((a, b) {
      final da = DateTime.parse(a['creation_time']);
      final db = DateTime.parse(b['creation_time']);
      return db.compareTo(da); // 按时间从新到旧
    });

    // 构建 children 列表
    final List<Widget> children = [];

    // 添加 DrawerHeader
    children.add(drawerHeader());

    for (int i = 0; i < sortedHistory.length; i++) {
      final tab = sortedHistory[i];
      final date = DateTime.parse(tab['creation_time']);
      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      // 判断是否需要插入日期分隔符
      bool needDivider = true;
      if (i > 0) {
        final prevDate = DateTime.parse(sortedHistory[i - 1]['creation_time']);
        needDivider = !(prevDate.year == date.year &&
            prevDate.month == date.month &&
            prevDate.day == date.day);
      }
      if (needDivider) {
        children.add(
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            color: Colors.grey.shade200,
            child: Text(
              dateStr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        );
      }

      // 添加 Tab
      children.add(historyTab(tab: tab));
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: children,
      ),
    );
  }
}

