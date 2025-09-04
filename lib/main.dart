import 'package:flutter/material.dart';
import 'xiaotian/view/page/xiaotian_page.dart';
import 'package:provider/provider.dart';
import 'xiaotian/model/xiaotian_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => xiaotianChatState()),
          ChangeNotifierProvider(create: (_) => xiaotianInputState()),
        ],
      child:
      MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const XiaoTian_Page(),
    ));
  }
}
