import 'package:flutter/material.dart';

class MultiStateButton extends StatelessWidget {
  final List<String> icons; // Lista de rutas de imágenes
  final List<String> labels; // Lista de textos del estado
  final String title; // Texto fijo arriba del estado
  final int currentState; // Estado actual
  final Color borderColor;
  // Optional fixed width to keep the widget from shifting when label length changes
  final double width;
  final void Function() onPressed;

  const MultiStateButton({
    super.key,
    required this.icons,
    required this.labels,
    required this.title,
    required this.currentState,
    required this.borderColor,
    this.width = 120,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final String stateDescription = labels[currentState];
    final String semanticLabel =
        '$title: $stateDescription. Presiona para cambiar';

    return Semantics(
      button: true,
      label: semanticLabel,
      hint: 'Doble toque para cambiar el estado',
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onPressed,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Image.asset(
                  icons[currentState],
                  width: 40,
                  height: 40,
                  semanticLabel: stateDescription,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              labels[currentState],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.green),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
