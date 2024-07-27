import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:grab_laundry/db.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  // env.load();
  await openConnection();

  return serve(handler, ip, port);
}
