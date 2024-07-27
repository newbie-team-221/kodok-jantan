import 'package:postgres/postgres.dart';

// Konfigurasi koneksi PostgreSQL
late Connection conn;

// Fungsi untuk menutup koneksi
Future<void> openConnection() async {
  conn = await Connection.open(
    Endpoint(
      host: 'localhost', // Host PostgreSQL
      database: 'gajah', // Nama database
      username: 'sapta', // Username
      password: 'grab-laundry', // Password
    ),
    settings: const ConnectionSettings(
      sslMode: SslMode.disable,
      timeZone: 'Asia/Jakarta',
    ),
  );
  print('Connection to PostgreSQL database closed.');
}
