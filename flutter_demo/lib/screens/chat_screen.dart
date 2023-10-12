// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:grouped_list/grouped_list.dart';
// import 'package:intl/intl.dart';
// import 'package:try_chatbot2/models/messages_model.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:url_launcher/url_launcher.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   List<Message> messages = [
//     Message(
//       text: 'Ask me what items will be popular next season.',
//       date: DateTime.now().subtract(const Duration(minutes: 3)),
//       isSentByUser: false,
//     ),
//   ].reversed.toList();

//   final TextEditingController _textEditingController = TextEditingController();

//   @override
//   void dispose() {
//     _textEditingController.dispose();
//     super.dispose();
//   }

//   void sendMessage(String text) async {
//     final userMessage = Message(
//       text: text,
//       date: DateTime.now(),
//       isSentByUser: true,
//     );
//     const String serverEndpoint = 'http://127.0.0.1:8081';

//     setState(() {
//       messages.add(userMessage);
//       _textEditingController.text = '';
//     });

//     try {
//       final Map<String, dynamic> requestData = {
//         'text': text,
//       };

//       final response = await http.post(
//         Uri.parse(serverEndpoint),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestData),
//       );

//       final responseBody = jsonDecode(response.body);

//       if (responseBody.containsKey('response_text') &&
//           responseBody['response_text'].isNotEmpty) {
//         final String responseText = responseBody['response_text'];
//         final botMessage = Message(
//           text: responseText,
//           date: DateTime.now(),
//           isSentByUser: false,
//         );
//         setState(() {
//           messages.add(botMessage);
//         });
//       } else if (responseBody.containsKey('response_image')) {
//         final List<dynamic> linkList = responseBody['response_link'];
//         final List<dynamic> imageList = responseBody['response_image'];

//         for (int i = 0; i < linkList.length; i++) {
//           final String link = linkList[i];
//           final List<int> image = base64.decode(imageList[i]);
//           print(link);
//           print(image);

//           final botMessage = Message(
//             text: '',
//             date: DateTime.now(),
//             isSentByUser: false,
//             link: link,
//             image: image,
//           );

//           setState(() {
//             messages.add(botMessage);
//           });
//         }
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AppBar(
//           backgroundColor: Theme.of(context).primaryColor,
//           title: const Text(
//             'TRENDSETTER',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.symmetric(
//             vertical: 30,
//             horizontal: 20,
//           ),
//           child: Column(
//             children: [
//               Expanded(
//                 child: GroupedListView<Message, DateTime>(
//                   padding: const EdgeInsets.all(8),
//                   reverse: true,
//                   order: GroupedListOrder.DESC,
//                   elements: messages,
//                   groupBy: (message) => DateTime(
//                     message.date.year,
//                     message.date.month,
//                     message.date.day,
//                   ),
//                   groupHeaderBuilder: (Message message) => SizedBox(
//                     height: 50,
//                     child: Center(
//                       child: Card(
//                         color: Theme.of(context).primaryColor,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8),
//                           child: Text(
//                             DateFormat.yMMMd().format(message.date),
//                             style: const TextStyle(
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   itemBuilder: (context, Message message) {
//                     bool isUserMessage = message.isSentByUser;
//                     Color backgroundColor = isUserMessage
//                         ? Theme.of(context).primaryColor
//                         : Colors.white;

//                     return Align(
//                       alignment: isUserMessage
//                           ? Alignment.centerRight
//                           : Alignment.centerLeft,
//                       child: Card(
//                         elevation: 8,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16.0),
//                           side: BorderSide(
//                             color: isUserMessage
//                                 ? Colors.transparent
//                                 : Colors.grey.shade300,
//                             width: 1.0,
//                           ),
//                         ),
//                         color: backgroundColor,
//                         child: Padding(
//                           padding: const EdgeInsets.all(10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 message.text,
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                   color: isUserMessage
//                                       ? Colors.white
//                                       : Colors.black,
//                                 ),
//                               ),
//                               if (message.image != null)
//                                 Image.memory(
//                                   Uint8List.fromList(message.image!),
//                                   width: 150,
//                                   height: 150,
//                                 ),
//                               if (message.link != null &&
//                                   message.link!.isNotEmpty)
//                                 GestureDetector(
//                                   onTap: () async {
//                                     final String urlString = message.link!;
//                                     final Uri uri = Uri.parse(urlString);
//                                     if (await canLaunchUrl(uri)) {
//                                       await launchUrl(uri);
//                                     } else {
//                                       print('Could not launch link');
//                                     }
//                                   },
//                                   child: Text(
//                                     message.link!,
//                                     style: const TextStyle(
//                                       color: Colors.blue,
//                                       decoration: TextDecoration.underline,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               Row(children: [
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(20.0),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: _textEditingController,
//                               decoration: const InputDecoration(
//                                 hintText: 'ex)recommend based on fw23 prada',
//                                 border: InputBorder.none,
//                               ),
//                               onSubmitted: (text) {
//                                 sendMessage(text);
//                               },
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               final text = _textEditingController.text;
//                               if (text.isNotEmpty) {
//                                 sendMessage(text);
//                               }
//                             },
//                             child: Icon(
//                               Icons.send,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ])
//             ],
//           ),
//         ),
//       );
// }

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:try_chatbot2/models/messages_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [
    Message(
      text: 'Ask me what items will be popular next season.',
      date: DateTime.now().subtract(const Duration(minutes: 3)),
      isSentByUser: false,
    ),
  ].reversed.toList();

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void sendMessage(String text) async {
    final userMessage = Message(
      text: text,
      date: DateTime.now(),
      isSentByUser: true,
    );
    const String serverEndpoint = 'http://127.0.0.1:8081';

    setState(() {
      messages.add(userMessage);
      _textEditingController.text = '';
    });

    try {
      final Map<String, dynamic> requestData = {
        'text': text,
      };

      final response = await http.post(
        Uri.parse(serverEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      final responseBody = jsonDecode(response.body);

      if (responseBody.containsKey('response_image')) {
        final List<dynamic> linkList = responseBody['response_link'];
        final List<dynamic> imageList = responseBody['response_image'];
        final String text = responseBody['response_text'];

        for (int i = 0; i < linkList.length; i++) {
          final String link = linkList[i];
          final List<int> image = base64.decode(imageList[i]);

          final botMessage = Message(
            text: i == 0 ? text : '',
            date: DateTime.now(),
            isSentByUser: false,
            link: link,
            image: image,
          );

          setState(() {
            messages.add(botMessage);
          });
        }
      } else {
        final String responseText = responseBody['response_text'];
        final botMessage = Message(
          text: responseText,
          date: DateTime.now(),
          isSentByUser: false,
        );
        setState(() {
          messages.add(botMessage);
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            'TRENDSETTER',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 30,
            horizontal: 20,
          ),
          child: Column(
            children: [
              Expanded(
                child: GroupedListView<Message, DateTime>(
                  padding: const EdgeInsets.all(8),
                  reverse: true,
                  order: GroupedListOrder.DESC,
                  elements: messages,
                  groupBy: (message) => DateTime(
                    message.date.year,
                    message.date.month,
                    message.date.day,
                  ),
                  groupHeaderBuilder: (Message message) => SizedBox(
                    height: 50,
                    child: Center(
                      child: Card(
                        color: Theme.of(context).primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            DateFormat.yMMMd().format(message.date),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  itemBuilder: (context, Message message) {
                    bool isUserMessage = message.isSentByUser;
                    Color backgroundColor = isUserMessage
                        ? Theme.of(context).primaryColor
                        : Colors.white;

                    return Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: BorderSide(
                            color: isUserMessage
                                ? Colors.transparent
                                : Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                        color: backgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.text,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isUserMessage
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              if (message.image != null)
                                Image.memory(
                                  Uint8List.fromList(message.image!),
                                  width: 150,
                                  height: 150,
                                ),
                              if (message.link != null &&
                                  message.link!.isNotEmpty)
                                GestureDetector(
                                  onTap: () async {
                                    final String urlString = message.link!;
                                    final Uri uri = Uri.parse(urlString);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    } else {
                                      print('Could not launch link');
                                    }
                                  },
                                  child: Text(
                                    message.link!,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textEditingController,
                              decoration: const InputDecoration(
                                hintText: 'ex)recommend based on fw23 prada',
                                // hintText: 'Please include "recommend"!',
                                border: InputBorder.none,
                              ),
                              onSubmitted: (text) {
                                sendMessage(text);
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              final text = _textEditingController.text;
                              if (text.isNotEmpty) {
                                sendMessage(text);
                              }
                            },
                            child: Icon(
                              Icons.send,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ])
            ],
          ),
        ),
      );
}
