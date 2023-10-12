// 화면 녹화 : terminal 열고 경로 확인하고(명령어 맨 뒤가 경로)
//xcrun simctl io 546B2563-890D-468A-9702-679199290E13 recordVideo /Users/yena/Desktop/python_study/Flutter/demo.mp4
// 녹화 종료 : Ctrl + C
import 'package:flutter/material.dart';
import 'package:try_chatbot2/screens/home_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFF3A1B0F),
      ),
      home: const HomeScreen(), // 홈 화면을 HomeScreen으로 변경
    );
  }
}
