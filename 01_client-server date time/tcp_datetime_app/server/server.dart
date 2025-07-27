import 'dart:io';

void main() async {
  try {
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, 8080);
    print('Server started on ${server.address.address}:${server.port}');

    await for (Socket client in server) {
      print('Client connected: ${client.remoteAddress.address}');

      String dateTime = DateTime.now().toString();

      client.write('Current Date & Time: $dateTime\n');

      await client.close();
      print('Client disconnected: ${client.remoteAddress.address}');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}