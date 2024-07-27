import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:grab_laundry/db.dart';
// Import package PostgreSQL

Future<Response> onRequest(RequestContext context, String serviceId) async {
  // Hanya menerima GET request
  if (context.request.method != HttpMethod.get) {
    return Response.json(
      body: {
        'status': false,
        'message': 'Invalid request method. Please use POST.',
        'data': {},
      },
      statusCode: 405, // Method Not Allowed
    );
  }

  // Mengambil merchant_id dari path parameter
  final merchantId = context.request.uri.pathSegments.last;

  // Validasi merchant_id
  if (merchantId.isEmpty || int.tryParse(merchantId) == null) {
    return Response.json(
      body: {
        'status': false,
        'message': 'Invalid or missing merchant_id',
        'data': {},
      },
      statusCode: 405, // Method Not Allowed
    );
  }

  // Menjalankan query untuk mendapatkan layanan berdasarkan merchant_id
  final results = await conn.execute('''
    SELECT json_agg(
              json_build_object(
                  'service_name', s.name,
                  'weight_price', p.weight_price,
                  'item_prices', (
                      SELECT json_agg(
                          json_build_object(
                              'name', i.name,
                              'unit_price', ip.unit_price
                          )
                      )
                      FROM ItemPrice ip
                      JOIN Item i ON ip.item_id = i.id
                      WHERE ip.price_id = p.id
                  )
              )
          ) AS service_details
    FROM Service s
    JOIN Price p ON s.id = p.service_id
    WHERE s.id = $serviceId;
  ''');

  print(results);

  // Mengonversi hasil query menjadi list of maps
  final services = results.map((row) {
    return {
      'service_name': row[0],
    };
  }).toList();

  // Mengembalikan response JSON
  return Response.json(body: {
    'success': true,
    'message': 'success get list merchant',
    'data': services,
  });
}
