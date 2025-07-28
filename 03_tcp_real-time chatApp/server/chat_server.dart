import 'dart:io';

/// সকল ক্লায়েন্টের তালিকা রাখা হবে
List<Socket> clients = [];

void main() async {
  try {
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, 8082);
    print('Chat Server started on ${server.address.address}:${server.port}');

    await for (Socket client in server) {
      print('Client connected: ${client.remoteAddress.address}');
      clients.add(client);

      // ক্লায়েন্ট থেকে মেসেজ শোনা
      client.listen((data) {
        String message = String.fromCharCodes(data).trim();
        print('Received: $message');

        // সকল ক্লায়েন্টকে মেসেজ পাঠানো (broadcast)
        for (var c in clients) {
          if (c != client) {
            c.write('User: $message from Server\n');
          }
        }
      }, onDone: () {
        print('Client disconnected: ${client.remoteAddress.address}');
        clients.remove(client);
      });
    }
  } catch (e) {
    print('Error: $e');
  }
}
