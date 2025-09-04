import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/history_widget.dart';
import '../widget/chat_widget.dart';
import '../../model/xiaotian_state.dart';

class XiaoTian_Page extends StatefulWidget {
  const XiaoTian_Page({super.key});

  @override
  State<XiaoTian_Page> createState() => _XiaoTian_PageState();
}

class _XiaoTian_PageState extends State<XiaoTian_Page> {

  @override
  void initState() {
    //TODO:刚进入时，获取一个新会话,开启一个新页面
    ///context.read<xiaotianChatState>().setSessionId(id);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => xiaotianChatState()),
        ChangeNotifierProvider(create: (_) => xiaotianInputState()),
      ],
      child: Scaffold(
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
      ),
    );
  }
}
