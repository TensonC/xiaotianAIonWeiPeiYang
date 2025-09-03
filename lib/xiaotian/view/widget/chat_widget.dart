import 'package:flutter/material.dart';
import 'package:xiaotian/xiaotian/view/widget/bubble_widget.dart';
import '../widget/bubble_widget.dart';
import '../../model/xiaotian_state.dart';
import 'package:provider/provider.dart';

Widget openNewChatButton()
{
  return IconButton(
      onPressed: (){
        //打开一个新页面
      },
      icon: const Icon(Icons.add)
  );
}

//开启新页面的占位贴图
class newChatTile extends StatelessWidget {
  const newChatTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Hi，同学你好！我是你们24小时不下线的AI辅导员“小天老师”～很高兴见到你',textAlign:TextAlign.center,style: TextStyle(
                fontSize: 20,fontWeight: FontWeight.w700
              ),),
              SizedBox(height: 10,),
              Text('我努力为你提供精准、智能、高效的校内信息咨询服务',textAlign:TextAlign.center,style: TextStyle(
                fontSize: 14
              ),),
              SizedBox(height: 10,),
              Text('(因为我也刚刚和大家见面,我的回答仅供参考,有误的地方请你批评指正哦～快来和我一起开启这段超棒的问答旅程吧～🚀)',textAlign:TextAlign.center,style: TextStyle(
                fontSize: 14
              ),)
            ],
          )
      ),
    );
  }
}

class ChatTile extends StatefulWidget {
  const ChatTile({super.key});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<xiaotianChatState>
      (builder: (context,chatState,_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
        });
        return ListView.builder(
            controller: _scrollController,
            itemCount: chatState.messages.length,
            itemBuilder: (context,index) {
              final msg = chatState.messages[index];
              final role = msg["role"] as String;
              return role == 'user' ? bubbleFromUser(text: msg["content"] as String) :
              bubbleFromAi(text: msg["content"] as String, source: msg["source"], followup: msg["followup"]);
            }
        );
      }
    );
  }
}



//输入框
class inputBox extends StatefulWidget {
  const inputBox({super.key});

  @override
  State<inputBox> createState() => _inputBoxState();
}

class _inputBoxState extends State<inputBox> {
  final FocusNode _focusNode = FocusNode();
  final _textController = TextEditingController();

  void onEdit(String content) {
    _textController.text = content;
    _focusNode.hasFocus;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //发消息
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            onTapOutside: (e) => _focusNode.unfocus(),
            keyboardType: TextInputType.multiline,
            maxLines: 2,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: '给小天老师发消息',
            ),
          ),
          //底部栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    //添加联网搜索
                  },
                  icon: const Icon(Icons.language_rounded)),
              Row(
                children: [
                  IconButton(
                      onPressed: (){
                        //添加链接文件
                      },
                      icon: const Icon(Icons.link_off_rounded)
                  ),
                  IconButton(
                      onPressed: (){
                        //发送
                        xiaotianChatState().messageAdd({"role":"user","file":false,"content":_textController.text});
                      },
                      icon: const Icon(Icons.send_rounded)
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}


