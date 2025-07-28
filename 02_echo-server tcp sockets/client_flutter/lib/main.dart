import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const EchoApp());
}

class EchoApp extends StatelessWidget {
  const EchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TCP Echo Client',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const EchoPage(),
    );
  }
}

class EchoPage extends StatefulWidget {
  const EchoPage({super.key});

  @override
  _EchoPageState createState() => _EchoPageState();
}

class _EchoPageState extends State<EchoPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String response = "No response yet...";

  late AnimationController _controllerAnim;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  @override
  void initState() {
    super.initState();
    _controllerAnim = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _color1 = ColorTween(begin: Colors.green, end: Colors.lightGreenAccent)
        .animate(_controllerAnim);
    _color2 = ColorTween(begin: Colors.teal, end: Colors.greenAccent)
        .animate(_controllerAnim);
  }

  @override
  void dispose() {
    _controllerAnim.dispose();
    super.dispose();
  }

  Future<void> sendMessage() async {
    final message = _controller.text;
    if (message.isEmpty) return;

    try {
      final socket = await Socket.connect('192.168.0.3', 8081)
          .timeout(const Duration(seconds: 10));

      // মেসেজ সার্ভারে পাঠানো
      socket.write(message);

      // মেসেজ পাঠানোর পর TextField খালি করে দাও
      _controller.clear();

      // সার্ভারের রিপ্লাই শোনা
      socket.listen((data) {
        setState(() {
          response = String.fromCharCodes(data);
        });
        socket.destroy();
      });
    } catch (e) {
      setState(() {
        response = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controllerAnim,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _color1.value ?? Colors.green,
                  _color2.value ?? Colors.teal
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.message_rounded,
                            size: 80, color: Colors.white.withOpacity(0.9)),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _controller,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                          decoration: InputDecoration(
                            labelText: 'Enter your message',
                            labelStyle: const TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  const BorderSide(color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: sendMessage,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            backgroundColor: Colors.white.withOpacity(0.8),
                            foregroundColor: Colors.green.shade800,
                          ),
                          child: const Text(
                            "Send to Server",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          response,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
