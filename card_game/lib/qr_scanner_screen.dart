// qr_scanner_screen.dart
import 'package:flutter/material.dart';

// На Web всегда показываем Web версию
class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const QRScannerWeb();
  }
}


// Для Web версии
class QRScannerWeb extends StatefulWidget {
  const QRScannerWeb({super.key});

  @override
  State<QRScannerWeb> createState() => _QRScannerWebState();
}

class _QRScannerWebState extends State<QRScannerWeb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00926E),
      appBar: AppBar(
        title: const Text('Сканер QR-кода'),
        backgroundColor: const Color(0xFF00926E),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_2,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'QR сканер работает на мобильных устройствах',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Откройте это приложение на вашем смартфоне или планшете для сканирования QR кодов.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 32,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'Вернуться',
                style: TextStyle(
                  color: Color(0xFF00926E),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}