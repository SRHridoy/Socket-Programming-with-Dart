import 'dart:io';

/// এটি একটি সাধারণ Echo Server.
/// ক্লায়েন্ট যা পাঠাবে, সার্ভার সেটি ফেরত পাঠাবে।
void main() async {
  try {
    // সার্ভার 8081 পোর্টে লিসেন করবে।
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, 8081);
    print('Echo Server started on ${server.address.address}:${server.port}');

    // যখন নতুন ক্লায়েন্ট কানেক্ট হবে, এই লুপ চলবে।
    await for (Socket client in server) {
      print('Client connected: ${client.remoteAddress.address}');

      // ক্লায়েন্ট থেকে ডেটা শোনা।
      client.listen((data) {
        String message = String.fromCharCodes(data);
        print('Received: $message');

        // ক্লায়েন্টকে একই মেসেজ ফিরিয়ে দেওয়া।
        client.write('Echo: $message from Server!');
      }, onDone: () {
        // ক্লায়েন্ট ডিসকানেক্ট হলে বার্তা দেখাবে।
        print('Client disconnected: ${client.remoteAddress.address}');
      });
    }
  } catch (e) {
    print('Error: $e');
  }
}
