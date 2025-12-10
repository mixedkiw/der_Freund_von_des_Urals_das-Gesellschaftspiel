import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'game_field_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late MobileScannerController cameraController;
  final List<int> scannedCards = []; // Отсканированные номера карт
  bool isScanning = true;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      autoStart: true,
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    // Если уже отсканировали 3 карты, ничего не делаем
    if (scannedCards.length >= 3 || !isScanning) {
      return;
    }

    for (final barcode in barcodes.barcodes) {
      final String? rawValue = barcode.rawValue;
      
      if (rawValue != null && rawValue.isNotEmpty) {
        // Пытаемся парсить номер из QR кода (цифра 1-9)
        try {
          final int cardNumber = int.parse(rawValue);
          
          if (cardNumber >= 1 && cardNumber <= 9) {
            // Валидная карта!
            setState(() {
              scannedCards.add(cardNumber);
              isScanning = false; // Приостанавливаем сканирование
            });

            // Показываем уведомление
            _showCardAddedNotification(cardNumber);
            
            // Если отсканировали 3 карты, переходим на экран поворота
            if (scannedCards.length == 3) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          _RotateScreenWrapper(cardNumbers: scannedCards),
                    ),
                  );
                }
              });
            } else {
              // Иначе возобновляем сканирование через 1.5 секунды
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (mounted) {
                  setState(() {
                    isScanning = true;
                  });
                }
              });
            }
            break; // Обрабатываем только первый распознанный баркод
          }
        } catch (e) {
          // Игнорируем QR коды которые не являются цифрами
          debugPrint('Ошибка парсинга QR: $rawValue');
        }
      }
    }
  }

  void _showCardAddedNotification(int cardNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✓ Карта добавлена'),
        content: Text('Карта $cardNumber была добавлена в вашу колоду'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerError(
    BuildContext context,
    MobileScannerException error,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, color: Colors.red, size: 64),
        const SizedBox(height: 16),
        Text('Ошибка камеры: $error'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR сканер'),
        backgroundColor: const Color(0xFF00926E),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Камера
          MobileScanner(
            controller: cameraController,
            onDetect: isScanning ? _handleBarcode : null,
            errorBuilder: _buildScannerError,
            placeholderBuilder: (context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          // UI сверху камеры
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Рамка сканирования
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 40),
                // Текст с информацией о сканировании
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Сканировано карт: ${scannedCards.length}/3',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Инструкция внизу
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Направьте камеру на QR код\nс номером карты (1-9)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Промежуточный экран "Переверните телефон"
class _RotateScreenWrapper extends StatefulWidget {
  final List<int> cardNumbers;

  const _RotateScreenWrapper({required this.cardNumbers});

  @override
  State<_RotateScreenWrapper> createState() => _RotateScreenWrapperState();
}

class _RotateScreenWrapperState extends State<_RotateScreenWrapper> {
  @override
  void initState() {
    super.initState();
    
    // Устанавливаем только ландшафтную ориентацию
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).catchError((_) {});

    // Показываем это окно 2.5 секунды, потом переходим на игровое поле
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                GameFieldScreen(cardNumbers: widget.cardNumbers),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00926E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '↻',
              style: TextStyle(
                fontSize: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Переверните телефон',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Подождите секунду...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}