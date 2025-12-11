import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// ⏳ Micro-SaaS Factory: Loading Overlay
/// 
/// Full-screen loading overlay for async operations.
/// Used during purchases, exports, and other long operations.
/// 
/// Usage:
/// ```dart
/// LoadingOverlay.show(context, message: 'Processing...');
/// // ... async operation
/// LoadingOverlay.hide(context);
/// ```

class LoadingOverlay extends StatelessWidget {
  final String? message;
  
  const LoadingOverlay({
    super.key,
    this.message,
  });
  
  /// Show the loading overlay
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => LoadingOverlay(message: message),
    );
  }
  
  /// Hide the loading overlay
  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 20),
                Text(
                  message!,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple inline loading indicator
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  
  const LoadingIndicator({
    super.key,
    this.size = 24,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color ?? AppColors.primary,
        strokeWidth: 2,
      ),
    );
  }
}
