import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TCP Chat Client',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<String> messages = [];
  final ScrollController _scrollController = ScrollController();
  Socket? socket;

  late AnimationController _bgController;
  late Animation<Color?> _bgColor1;
  late Animation<Color?> _bgColor2;

  @override
  void initState() {
    super.initState();
    connectToServer();

    // ব্যাকগ্রাউন্ড অ্যানিমেশন কন্ট্রোলার
    _bgController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _bgColor1 = ColorTween(begin: Colors.deepPurple, end: Colors.indigo)
        .animate(_bgController);
    _bgColor2 = ColorTween(begin: Colors.purple, end: Colors.blueAccent)
        .animate(_bgController);
  }

  @override
  void dispose() {
    _bgController.dispose();
    socket?.close();
    super.dispose();
  }

  /// সার্ভারের সাথে সংযোগ স্থাপন
  Future<void> connectToServer() async {
    try {
      socket = await Socket.connect('192.168.0.3', 8082)
          .timeout(const Duration(seconds: 10));
      socket!.listen((data) {
        addMessage(String.fromCharCodes(data).trim());
      });
    } catch (e) {
      addMessage('Error connecting: $e');
    }
  }

  /// নতুন মেসেজ অ্যাড করে অটো স্ক্রল
  void addMessage(String msg) {
    setState(() {
      messages.add(msg);
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// সার্ভারে মেসেজ পাঠানো
  void sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty && socket != null) {
      socket!.write(message);
      addMessage('Me: $message');
      _controller.clear(); // ইনপুট খালি
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // কীবোর্ডে UI ঝাঁকুনি বন্ধ
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_bgColor1.value ?? Colors.deepPurple, _bgColor2.value ?? Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'TCP Chat Client',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.startsWith('Me:');
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.white.withOpacity(0.3)
                              : Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          msg,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          hintText: 'Enter message',
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: sendMessage,
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        backgroundColor: Colors.white.withOpacity(0.8),
                        foregroundColor: Colors.deepPurple,
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
