import 'package:dart_frog/dart_frog.dart';
import 'package:grab_laundry/db.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'success': true,
      'message': 'Success Fetch API',
      // ignore: inference_failure_on_collection_literal
      'data': {},
    },
  );
}
