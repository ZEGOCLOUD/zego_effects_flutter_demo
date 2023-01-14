import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';


class ZegoUtils {
  static showAlert(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Tips'),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}

Future<Map<String, dynamic>> HttpGet(String url) async {
  HttpClient httpClient = new HttpClient();
  HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
  request.headers.set('content-type', 'application/json');
  HttpClientResponse response = await request.close();
  String reply = await response.transform(utf8.decoder).join();
  httpClient.close();
  return json.decode(reply);
}