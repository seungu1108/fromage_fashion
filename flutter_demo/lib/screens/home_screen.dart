import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:try_chatbot2/screens/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String url =
      'https://www.brandi.co.kr/?NaPm=ct%3Dln4ch47x%7Cci%3Dcheckout%7Ctr%3Dds%7Ctrx%3Dnull%7Chk%3D74536d76da35d4e7ff7757cf81fc5e9769d6a43d';

  bool isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          top: 50,
          bottom: 20,
        ),
        child: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Positioned(
            bottom: 30,
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  isButtonPressed = true;
                });
              },
              onTapUp: (_) {
                setState(() {
                  isButtonPressed = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isButtonPressed ? 70 : 60, // 버튼을 누를 때 크기 변경
                height: isButtonPressed ? 70 : 60, // 버튼을 누를 때 크기 변경
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isButtonPressed
                      ? Colors.grey
                      : Theme.of(context).primaryColor, // 배경색 변경
                ),
                child: Center(
                  child: ClipOval(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset('assets/logo.png'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
