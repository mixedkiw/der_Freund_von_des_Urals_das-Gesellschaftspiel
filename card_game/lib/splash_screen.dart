import 'package:flutter/material.dart';

/// Загрузочный экран с вращающимися карточками
///
/// Кастомизация:
/// - Измени [cardColors] для изменения цветов фона
/// - Измени [cycleDuration] для изменения скорости анимации (в миллисекундах)
class SplashScreen extends StatefulWidget {
  final VoidCallback onLoadComplete;

  const SplashScreen({
    super.key,
    required this.onLoadComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ========== КАСТОМИЗАЦИЯ ==========
  /// Цвета фона для переключения
  static const List<Color> cardColors = [
    Color(0xFFFF9500), // Оранжевый
    Color(0xFF4CAF50), // Зелёный
    Color(0xFF9C27B0), // Фиолетовый
  ];

  /// Длительность одной полной итерации (все карточки переворачиваются и меняется цвет)
  /// в миллисекундах (3000 мс = 3 сек)
  static const int cycleDuration = 3000;

  /// Количество карточек
  static const int cardCount = 3;

  /// Тексты загрузки - меняй на свои!
  static const List<String> loadingTexts = [
    'Заставляем сканер работать',
    'Распаковываем колоду карт',
    'Выдаём проблемы лидерам',
    'Готовим поле боя',
    'Калибруем кубики удачи',
  ];

  // ================================

  late AnimationController _mainController;
  late Animation<double> _colorAnimation;

  int _currentColorIndex = 0;
  int _currentTextIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Один контроллер для всей анимации (карточки + смена цвета)
    _mainController = AnimationController(
      duration: const Duration(milliseconds: cycleDuration),
      vsync: this,
    );

    _colorAnimation = Tween<double>(begin: 0, end: 1).animate(_mainController);

    // Запускаем анимацию с циклом
    _startAnimationCycle();

    // Имитируем загрузку (продолжительность зависит от реальной загрузки данных)
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _completeLoading();
      }
    });
  }

  void _startAnimationCycle() {
    _mainController.forward().then((_) {
      if (mounted && _isLoading) {
        // Переключаемся на следующий цвет и текст
        _currentColorIndex = (_currentColorIndex + 1) % cardColors.length;
        _currentTextIndex = (_currentTextIndex + 1) % loadingTexts.length;
        setState(() {});
        // Перезапускаем анимацию
        _mainController.reset();
        _startAnimationCycle();
      }
    });
  }

  void _completeLoading() {
    setState(() {
      _isLoading = false;
    });
    _mainController.stop();
    widget.onLoadComplete();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        // Плавное переключение цветов (происходит за 200ms в конце цикла)
        final colorChangeProgress = (_mainController.value - 0.85).clamp(0, 1) / 0.15;
        
        Color bgColor = Color.lerp(
          cardColors[_currentColorIndex],
          cardColors[(_currentColorIndex + 1) % cardColors.length],
          colorChangeProgress,
        )!;

        return Container(
          color: bgColor,
          // Текст внизу экрана
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Анимированные карточки
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        cardCount,
                        (index) => AnimatedCard(
                          mainAnimation: _mainController,
                          cardIndex: index,
                          totalCards: cardCount,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Текст загрузки внизу
              if (_isLoading)
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      loadingTexts[_currentTextIndex],
                      key: ValueKey(_currentTextIndex),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Виджет одной карточки с анимацией переворота
class AnimatedCard extends StatelessWidget {
  final AnimationController mainAnimation;
  final int cardIndex;
  final int totalCards;

  /// Время переворота одной карточки в миллисекундах
  static const int flipDuration = 400;

  const AnimatedCard({
    super.key,
    required this.mainAnimation,
    required this.cardIndex,
    required this.totalCards,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mainAnimation,
      builder: (context, child) {
        // Вычисляем когда должна переворачиваться эта карточка
        // Общее время = cycleDuration (3000ms)
        // Каждая карточка переворачивается за flipDuration (400ms)
        // Задержка между карточками = (cycleDuration - flipDuration) / totalCards
        
        final totalDurationMs = 3000; // cycleDuration
        final delayBetween = (totalDurationMs - flipDuration) / totalCards;
        final flipStartTime = cardIndex * delayBetween;
        final flipEndTime = flipStartTime + flipDuration;

        // Нормализуем время анимации (0 to 1)
        final currentTimeMs = mainAnimation.value * totalDurationMs;

        // Вычисляем прогресс переворота для этой карточки (0 to 1)
        double flipProgress = 0;
        if (currentTimeMs >= flipStartTime && currentTimeMs <= flipEndTime) {
          flipProgress = (currentTimeMs - flipStartTime) / flipDuration;
        } else if (currentTimeMs > flipEndTime) {
          flipProgress = 1;
        }

        // Применяем 3D эффект переворота
        final angle = flipProgress * 3.14159; // π - полный оборот

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: Container(
            width: 40,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}