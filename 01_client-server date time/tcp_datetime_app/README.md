# **🍎 ক্লায়েন্ট-সার্ভার ডেট টাইম অ্যাপ (গল্পের মতো)**

এই অ্যাপটা এমন – **একজন (সার্ভার) জানে সময় কত বাজে**, আর **অন্যজন (ক্লায়েন্ট) সময় জানতে চায়।**
যখন বাচ্চা (ক্লায়েন্ট) বলে – *“ভাইয়া, সময় কতো?”* তখন বড় ভাই (সার্ভার) তাকে উত্তর দেয় – *“এই নাও, এখন ৫টা বেজে ৩০ মিনিট।”*

---

## **কিছু শব্দ মনে রাখো:**

* **সকেট প্রোগ্রামিং:** এটা হলো ফোন লাইন খোলার মতো। যেটা দিয়ে দু’জন কথা বলে।
* **TCP/IP:** এটা হলো খুব নিরাপদ ফোন কল – সব কথা ঠিকভাবে পৌঁছাবে।
* **ডার্ট (Dart):** ভাইয়া যে ভাষায় কথা বলছে।
* **ফ্লাটার (Flutter):** তুমি যে সুন্দর মোবাইল অ্যাপ দিয়ে জিজ্ঞেস করছো।

---

## **কিভাবে এই গেম খেলবে (প্রজেক্ট চালাবে)**

### **১. ভাইয়া (সার্ভার) চালু করো**

1. `server` ঘরে (ফোল্ডারে) ঢুকো।

   ```bash
   cd server
   ```
2. ভাইয়া (server.dart) কে জাগিয়ে দাও:

   ```bash
   dart server.dart
   ```

   এখন ভাইয়া ফোনের পাশে দাঁড়িয়ে বলবে – *“আমি 8080 নাম্বার ফোন লাইনে আছি।”*

---

### **২. তুমি (ক্লায়েন্ট) অ্যাপ চালাও**

1. `client_flutter` ঘরে ঢুকো।

   ```bash
   cd client_flutter
   ```
2. `lib/main.dart` ফাইলে **ভাইয়ার ফোন নাম্বার (IP)** সঠিকভাবে লিখো।
   *(যদি তুমি একই কম্পিউটারে খেলা করো, তাহলে `'127.0.0.1'` লিখতে পারো।)*
3. এখন অ্যাপ চালাও:

   ```bash
   flutter run
   ```

---

## **কোডটা কেমন করে কাজ করে?**

---

### **ভাইয়ার কাজ (server/server.dart):**

```dart
import 'dart:io';

void main() async {
  try {
    // 8080 নাম্বার ফোন লাইন খোলে।
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, 8080);
    print('Server started on ${server.address.address}:${server.port}');

    // যতক্ষণ না তুমি ফোন করছো, ভাইয়া অপেক্ষা করবে।
    await for (Socket client in server) {
      print('Client connected: ${client.remoteAddress.address}');

      // সময় দেখে।
      String dateTime = DateTime.now().toString();

      // তোমাকে বলে দেয়।
      client.write('Current Date & Time: $dateTime\n');

      // কাজ শেষে ফোন কেটে দেয়।
      await client.close();
      print('Client disconnected: ${client.remoteAddress.address}');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}
```

**বোঝার জন্য ছোট্ট নোট:**

* **ServerSocket.bind:** ভাইয়া ফোনে কানেক্ট হওয়ার জন্য প্রস্তুত থাকে (8080 নম্বর লাইনে)।
* **await for:** যখন তুমি কল দাও, ভাইয়া শোনে।
* **client.write:** ভাইয়া তোমাকে সময় বলে দেয়।
* **client.close:** ভাইয়া কল কেটে দেয়।

---

### **তোমার কাজ (client\_flutter/lib/main.dart):**

```dart
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TCP DateTime Client',
      home: DateTimePage(),
    );
  }
}

class DateTimePage extends StatefulWidget {
  const DateTimePage({super.key});

  @override
  _DateTimePageState createState() => _DateTimePageState();
}

class _DateTimePageState extends State<DateTimePage> {
  String serverResponse = "Waiting for response...";

  Future<void> fetchDateTime() async {
    try {
      // ভাইয়ার ফোন নাম্বার 192.168.0.3 এবং 8080।
      final socket = await Socket.connect(
        '192.168.0.3', 8080).timeout(Duration(seconds: 20));

      // ভাইয়া যা বলছে সেটা শোনো।
      socket.listen((data) {
        setState(() {
          serverResponse = String.fromCharCodes(data);
        });
        socket.destroy(); // কল কেটে দাও।
      });
    } catch (e) {
      setState(() {
        serverResponse = "Error: $e"; // যদি কোনো সমস্যা হয়।
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TCP DateTime Client')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(serverResponse, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchDateTime,
              child: Text("Get Date & Time"),
            ),
          ],
        ),
      ),
    );
  }
}
```

**বোঝার জন্য ছোট্ট নোট:**

* **Socket.connect:** তুমি ভাইয়াকে কল দিচ্ছো।
* **listen:** ভাইয়া যা বলছে সেটা কানে শুনছো।
* **setState:** ফোনে লেখা দেখাচ্ছে।
* **socket.destroy:** কল শেষ করে দিচ্ছো।

---
