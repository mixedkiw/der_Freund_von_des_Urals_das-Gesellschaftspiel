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
    with TickerProviderStateMixin {
  late List<bool> isFlipped; // Флип состояние каждой карты
  late List<AnimationController> animationControllers;

  @override
  void initState() {
    super.initState();
    
    // Устанавливаем портретную ориентацию
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]).catchError((_) {});

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
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00926E),
      body: SafeArea(
        child: Stack(
          children: [
            // Главное игровое поле с картами в колонку
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  widget.cardNumbers.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
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
              child: GestureDetector(
                onTap: _exitGame,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF00926E),
                    size: 24,
                  ),
                ),
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
          
          // Поворот карты (от 0 до pi во время флипа) - только по Y оси
          final angle = flipValue * 3.14159265359;
          
          // Зеркалирование для issue стороны - только горизонтально
          final scaleX = isLeaderSide ? 1.0 : -1.0;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Перспектива
              ..rotateY(angle),
            child: Transform.scale(
              scaleX: scaleX,
              child: _buildCardWidget(
                cardNumber: cardNumber,
                isLeaderSide: isLeaderSide,
              ),
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
      width: 110,
      height: 165,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
        ],
      ),
    );
  }
}
