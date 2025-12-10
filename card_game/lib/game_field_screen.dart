import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Экран игрового поля с картами
class GameFieldScreen extends StatefulWidget {
  final List<int> cardNumbers; // Номера карт (1-9)

  const GameFieldScreen({
    super.key,
    required this.cardNumbers,
  });

  @override
  State<GameFieldScreen> createState() => _GameFieldScreenState();
}

class _GameFieldScreenState extends State<GameFieldScreen>
    with SingleTickerProviderStateMixin {
  late List<bool> isFlipped; // Флип состояние каждой карты
  late List<AnimationController> animationControllers;

  @override
  void initState() {
    super.initState();
    
    // Отложить установку ориентации чтобы избежать конфликта с ориентацией экрана
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        // Устанавливаем ландшафтную ориентацию
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]).catchError((_) {});
      }
    });

    // Инициализируем флипы (все карты показывают leader сторону - false)
    isFlipped = List.filled(widget.cardNumbers.length, false);
    
    // Создаём контроллеры анимации для каждой карты
    animationControllers = List.generate(
      widget.cardNumbers.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
  }

  @override
  void dispose() {
    // Возвращаемся на портретную ориентацию
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]).catchError((_) {});
    
    for (var controller in animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _flipCard(int index) {
    if (isFlipped[index]) {
      // Из флипа обратно в normal
      animationControllers[index].reverse();
    } else {
      // Из normal в flip
      animationControllers[index].forward();
    }
    setState(() {
      isFlipped[index] = !isFlipped[index];
    });
  }

  void _exitGame() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00926E),
      body: SafeArea(
        child: Stack(
          children: [
            // Главное игровое поле с картами
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.cardNumbers.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildFlipCard(
                      index,
                      widget.cardNumbers[index],
                    ),
                  ),
                ),
              ),
            ),
            // Кнопка выхода в левом верхнем углу
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                onPressed: _exitGame,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF00926E),
                mini: true,
                child: const Icon(Icons.exit_to_app),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlipCard(int index, int cardNumber) {
    return GestureDetector(
      onTap: () => _flipCard(index),
      child: AnimatedBuilder(
        animation: animationControllers[index],
        builder: (context, child) {
          // Flip animation: от 0 до 1
          final flipValue = animationControllers[index].value;
          
          // Когда достигаем 0.5, переключаемся на другую сторону
          final isLeaderSide = flipValue < 0.5;
          
          // Поворот карты (от 0 до pi во время флипа)
          final angle = flipValue * 3.14159265359;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Перспектива
              ..rotateY(angle),
            child: _buildCardWidget(
              cardNumber: cardNumber,
              isLeaderSide: isLeaderSide,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardWidget({
    required int cardNumber,
    required bool isLeaderSide,
  }) {
    final String imagePath = isLeaderSide
        ? 'assets/cards/${cardNumber}_leader.png'
        : 'assets/cards/${cardNumber}_issue.png';

    return Container(
      width: 150,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Попытка загрузить карту из assets
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback: показываем placeholder если карта не найдена
                return Container(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Карта $cardNumber',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00926E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isLeaderSide ? 'Leader' : 'Issue',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF00926E),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Поверх карты - информация (опционально)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isLeaderSide ? 'Tap to flip' : '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
