import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class bubbleFromAi extends StatefulWidget {
  const bubbleFromAi({super.key,required this.text,required this.source,required this.followup});

  final String text;                        //内容
  final List<Map<String,String>>? source;    //信息出处
  final String? followup;                    //相关问题

  @override
  State<bubbleFromAi> createState() => _bubbleFromAiState();
}

class _bubbleFromAiState extends State<bubbleFromAi> {
  late bool _openSource;

  @override
  void initState()
  {
    _openSource = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4,horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Text(
              widget.text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          //相关信息
          if ((widget.source?.isNotEmpty ?? false))
            CollapsibleSourceList(source: widget.source ?? []),

          if ((widget.followup?.isNotEmpty ?? false))
            followUp(widget.followup!, () {}),
          //底部按钮
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 25),
                onPressed: () =>Clipboard.setData(ClipboardData(text: widget.text)),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 25),
                onPressed: (){
                  //TODO:重新生成回答,即再往后端发一次
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}



//用户发言的气泡
class bubbleFromUser extends StatelessWidget {
  final String text;            // 消息内容

  const bubbleFromUser({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 聊天气泡
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4,horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          // 气泡下的按钮
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 25),
                onPressed: () =>Clipboard.setData(ClipboardData(text: text)),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 25),
                onPressed: (){
                  //TODO:重新编辑问题
                },
              ),
            ],
          ),
          //关联的文件

        ],
      ),
    );
  }
}

//可展开的信息组件
class CollapsibleSourceList extends StatefulWidget {
  final List<Map<String, String>> source; // 数据源

  const CollapsibleSourceList({
    Key? key,
    required this.source,
  }) : super(key: key);

  @override
  State<CollapsibleSourceList> createState() => _CollapsibleSourceListState();
}

class _CollapsibleSourceListState extends State<CollapsibleSourceList> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blueAccent.shade100,
      ),
      child: Column(
        children: [
          // 头部行
          Row(
            children: [
              Text('信息来源 ${widget.source.length}'),
              IconButton(
                onPressed: () {
                  setState(() {
                    _open = !_open;
                  });
                },
                icon: Icon(
                  _open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
              ),
            ],
          ),
          // 展开部分
          if (_open)
            Column(
              children: widget.source.map((src) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // 来源标题
                      Text(src['title'] ?? ''),
                      SizedBox(width: 10,),
                      // 来源类型
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          src['content_type'] == 'web' ? '网络' : '知识库',
                          style: TextStyle(
                            color: Colors.deepPurple.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

Widget followUp(String title,VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
      //发送关联问题
    child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical:10,horizontal: 12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade200
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.chevron_right)
          ],
        )
    ),
  );
}