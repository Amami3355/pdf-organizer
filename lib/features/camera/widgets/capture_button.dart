import 'package:flutter/material.dart';

/// 📷 Capture Button Widget
/// 
/// An animated circular button for capturing images.
/// Shows a pulsing animation when document is stable.

class CaptureButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isDocumentStable;
  final bool isCapturing;

  const CaptureButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
    this.isDocumentStable = false,
    this.isCapturing = false,
  });

  @override
  State<CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<CaptureButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(CaptureButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDocumentStable && !oldWidget.isDocumentStable) {
      _pulseController.forward();
    } else if (!widget.isDocumentStable && oldWidget.isDocumentStable) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEnabled && !widget.isCapturing ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = widget.isDocumentStable ? _pulseAnimation.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isCapturing
                  ? Colors.grey
                  : widget.isDocumentStable
                      ? const Color(0xFF4CAF50)
                      : Colors.white,
              width: 4,
            ),
            boxShadow: widget.isDocumentStable
                ? [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isCapturing
                    ? Colors.grey
                    : widget.isDocumentStable
                        ? const Color(0xFF4CAF50)
                        : Colors.white,
              ),
              child: widget.isCapturing
                  ? const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
