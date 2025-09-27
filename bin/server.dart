import 'dart:io';

void main() async {
  var server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('Server running on port 8080');
  await for (HttpRequest request in server) {
    request.response.write('Hello, Cloud Run!');
    await request.response.close();
  }
}