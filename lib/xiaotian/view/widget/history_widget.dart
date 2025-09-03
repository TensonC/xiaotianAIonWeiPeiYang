import 'package:flutter/material.dart';

Widget historyTab(BuildContext context,int index) {
  return GestureDetector(
    onTap: (){
      //进入对应历史页面
    },
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5)
      ),
      child: Text('title${index}'),
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