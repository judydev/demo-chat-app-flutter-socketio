import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.username});
  final String username;

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();

  late IO.Socket socket;
  List<Map<String, dynamic>> messages = [];

  final socketUrl = "http://localhost:8080"; // replace with your Cloud Run service URL
  
  @override
  void initState() {
    super.initState();

    // Connect to the Socket.IO server
    print('Connecting to Socket.IO server at $socketUrl');
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('Connected to server');
    });

    socket.on('message', (data) {
      print('Received message: $data');
      setState(() {
        messages.add(data);
      });
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text("Username: ${widget.username}"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['fromUsername'] == widget.username;
                              
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(message['message']),
                      ),
                    );
                  },
                ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final message = messageController.text;
                      if (message.isNotEmpty) {
                        final messageData = {
                          'fromUsername': widget.username,
                          'message': message,
                          'timestamp': DateTime.now().toIso8601String(),
                        };

                        setState(() {
                          messages.add(messageData);
                        });

                        socket.emit('message', messageData);
                        messageController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}