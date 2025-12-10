// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen.dart';
import 'qr_scanner_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // SystemChrome не работает на Web, поэтому заворачиваем в try-catch
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  } catch (e) {
    // Игнорируем ошибки на Web и других платформах
    debugPrint('Ориентация экрана не поддерживается');
  }
  
  // Добавляем обработку ошибок для debug
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Flutter error: ${details.exception}');
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Проблемы и суперкоманды',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00926E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFF00926E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00926E),
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const LoadingWrapper(),
    );
  }
}

/// Главный экран игры
class MainGameScreen extends StatelessWidget {
  const MainGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00926E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Логотип
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/Logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Color(0xFF00926E),
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Название игры
              const Text(
                'Проблемы и суперкоманды',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 30),
              // Описание игры
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Кажется, мы уже не раз слышали про команду мечты. Попробуем собрать её на практике и справиться с удивительными проблемами непростых проектов?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // Кнопка "Вперёд"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QRScannerScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Вперёд',
                    style: TextStyle(
                      color: Color(0xFF00926E),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Виджет-обертка для отображения загрузочного экрана
class LoadingWrapper extends StatefulWidget {
  const LoadingWrapper({super.key});

  @override
  State<LoadingWrapper> createState() => _LoadingWrapperState();
}

class _LoadingWrapperState extends State<LoadingWrapper> {
  bool _showHome = false;

  void _handleLoadComplete() {
    print('⏳ Загрузка завершена, переходим на главный экран');
    setState(() {
      _showHome = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🔵 LoadingWrapper build called, _showHome=$_showHome');
    if (!_showHome) {
      return SplashScreen(onLoadComplete: _handleLoadComplete);
    }
    return const MainGameScreen();
  }
}