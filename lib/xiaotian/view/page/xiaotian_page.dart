import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/history_widget.dart';
import '../widget/chat_widget.dart';
import '../../model/xiaotian_state.dart';
import '../../model/xiaotian_dio.dart';
import 'dart:convert';


class XiaoTian_Page extends StatefulWidget {
  const XiaoTian_Page({super.key});

  @override
  State<XiaoTian_Page> createState() => _XiaoTian_PageState();
}

class _XiaoTian_PageState extends State<XiaoTian_Page> {
  @override
  void initState() {
    // context.read<xiaotianChatState>().setSessionId('0');
    ///提前获取历史会话记录，防止打开侧边栏时卡顿
    _loadHistory();
    super.initState();
  }

  Future<void> _loadHistory() async {
    final sessions = await AiTjuApi().getAllSessions('3024004065');
    final list = sessions.map((e) => e.toJson()).toList();

    if (mounted) {
      Provider.of<xiaotianChatState>(context, listen: false)
          .setHistorySession(list);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.dashboard_rounded),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: const [openNewSession()],
      ),
      drawer: const historyDrawer(),
      body: Column(
        children: [
          Expanded(
            child: Consumer<xiaotianChatState>(
              builder: (context, chatState, _) {
                return chatState.sessionId == '0'
                    ? const newChatTile()
                    : const ChatTile();
              },
            ),
          ),
          //输入框
          const SafeArea(child: inputBox()),
        ],
      ),
    );
  }
}
