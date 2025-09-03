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
            }
        ),
        actions: [
          openNewChatButton()
        ],),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            drawerHeader(),
            ...List.generate(10, (index) => historyTab(context, index)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: xiaotianChatState().messages.isNotEmpty ?
            ChangeNotifierProvider<xiaotianChatState>.value(
              value: xiaotianChatState(),
              child: const ChatTile(),) : const newChatTile(),
          ),
          const SafeArea(
              child: inputBox()
          )
        ],
      ),
    );
  }
}
