import 'dart:convert';
import 'dart:math';
import 'package:dart_frog/dart_frog.dart';
import 'package:grab_laundry/db.dart';
import 'package:postgres/postgres.dart'; // Import package PostgreSQL

// Fungsi untuk menghitung jarak antara dua koordinat menggunakan rumus Haversine
double haversine(double lat1, double lon1, double lat2, double lon2) {
  const double R = 6371; // Radius bumi dalam kilometer
  final double dLat = _toRadians(lat2 - lat1);
  final double dLon = _toRadians(lon2 - lon1);
  final double a = (sin(dLat / 2) * sin(dLat / 2)) +
      (cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2));
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _toRadians(double degree) => degree * (pi / 180);

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      body: {
        'status': false,
        'message': 'Invalid request method. Please use POST.',
        'data': {},
      },
      statusCode: 405, // Method Not Allowed
    );
  }
  final body = await context.request.body();
  final data = jsonDecode(body);

  final num userLat = data['lat'] as double;
  final num userLong = data['long'] as double;
  // Menjalankan query untuk mendapatkan data merchant
  final results = await conn.execute('''
    SELECT json_agg(
              json_build_object(
                  'id', m.id,
                  'name', m.name,
                  'location', l.address,
                  'coordinate', json_build_object(
                      'lat', l.latitude,
                      'long', l.longitude
                  ),
                  'services', (
                      SELECT json_agg(
                          json_build_object(
                              'id', s.id,
                              'name', s.name
                          )
                      )
                      FROM Service s
                      WHERE s.merchant_id = m.id
                  ),
                  'rating', r.value
              )
          ) AS merchants
    FROM Merchant m
    JOIN Location l ON m.id = l.merchant_id
    LEFT JOIN Rating r ON m.rating_id = r.id;
  ''');

  // Mengonversi hasil query menjadi list of maps dan menghitung jarak
  List dataResult = results[0][0] as List<dynamic>;

  for (int i = 0; i < dataResult.length; i++) {
    final merchantLat = dataResult[i]['coordinate']['lat'] as double;
    final mercantLong = dataResult[i]['coordinate']['long'] as double;
    dataResult[i]['distance_km'] = haversine(
        userLat.toDouble(), userLong.toDouble(), merchantLat, mercantLong);
  }

  // Mengembalikan response JSON
  return Response.json(body: {
    'success': true,
    'message': 'success get list merchant',
    'data': dataResult,
  });
}
