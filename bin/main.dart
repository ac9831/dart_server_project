import 'dart:io';
import 'dart:convert';

Future main() async {
  var server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    4040,
  );
  print('Listeningon localhost:${server.port}');

  await for (HttpRequest request in server) {
    handleRequest(request);
  }
}

void handleRequest(HttpRequest request) {
  try {
    if (request.method == 'GET') {
      handleGet(request);
    } else if (request.method == 'POST') {
      handlePost(request);
    } else {
      request.response
        ..statusCode = HttpStatus.methodNotAllowed
        ..write('Unsupported request: ${request.method}.')
        ..close();
    }
  } catch (e) {
    print('Exception in handleRequest : $e');
  }
}

void handleGet(HttpRequest request) {
  final response = request.response;
  response
    ..writeln('Hi! This is Get Call!')
    ..close();
}

void handlePost(HttpRequest request) async {
  ContentType contentType = request.headers.contentType;
  HttpResponse res = request.response;

  if (contentType?.mimeType == 'application/json') {
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = jsonDecode(content) as Map;
      var fileName = request.uri.pathSegments.last;
      await File(fileName).writeAsString(content, mode: FileMode.write);
      res
        ..statusCode = HttpStatus.ok
        ..write('Wrote data for ${data['name']}.');
    } catch (e) {
      res
        ..statusCode = HttpStatus.internalServerError
        ..write("Exception during file I/O: $e.");
    }
  } else {
    res
      ..statusCode = HttpStatus.methodNotAllowed
      ..write("Unsuported request: ${request.method}.");
  }
  await res.close();
}
