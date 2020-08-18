import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:socket_io/socket_io.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

const String URI = "wss://beta.ethvigil.com/ws";
String key = "a03b152a-856e-4351-9884-26497e14690a";

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  IO.Socket socket = IO.io(URI);

  WebSocketChannel channel =
      IOWebSocketChannel.connect(URI, pingInterval: Duration(seconds: 20));

  _MyAppState() {
    channel.stream.listen((event) {
      print(event);

      var data = jsonDecode(event);

      print(data);
    });

    channel.sink.add(jsonEncode({
      "command": "register",
      "key": key,
    }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Socket example'),
          backgroundColor: Colors.black,
          elevation: 0.0,
        ),
        body: Container(color: Colors.black, child: Column()),
      ),
    );
  }
}
