import 'package:flutter/material.dart';

enum SnackBarStatus { success, error }

class SnackBars {
  SnackBars._();

  static void show({
    required BuildContext context,
    required SnackBarStatus status,
    required String message,
  }) {
    Color backgroundColor;

    switch (status) {
      case SnackBarStatus.success:
        backgroundColor = Colors.green;
        break;
      case SnackBarStatus.error:
        backgroundColor = Colors.red;
        break;
    }

    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: backgroundColor.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Status side bar
              Container(
                width: 6,
                height: 64,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Circular icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: backgroundColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status == SnackBarStatus.success
                      ? Icons.check_rounded
                      : Icons.error_outline_rounded,
                  color: backgroundColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Message
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Close button
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap:
                    () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
