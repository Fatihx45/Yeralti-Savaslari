import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MiningToastBadge extends StatefulWidget {
  final String? message;

  const MiningToastBadge({
    super.key,
    this.message,
  });

  @override
  State<MiningToastBadge> createState() => _MiningToastBadgeState();
}

class _MiningToastBadgeState extends State<MiningToastBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String? _displayMessage;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    if (widget.message != null && widget.message!.isNotEmpty) {
      _triggerMessage(widget.message!);
    }
  }

  @override
  void didUpdateWidget(covariant MiningToastBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message != null &&
        widget.message!.isNotEmpty &&
        widget.message != oldWidget.message) {
      _triggerMessage(widget.message!);
    }
  }

  void _triggerMessage(String msg) {
    _dismissTimer?.cancel();
    setState(() {
      _displayMessage = msg;
    });
    _controller.forward(from: 0.0);

    _dismissTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_displayMessage == null || _displayMessage!.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: Alignment.topRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 190, minWidth: 100),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xF20F0F2A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.goldText.withValues(alpha: 0.85),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldText.withValues(alpha: 0.25),
                blurRadius: 10,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.goldText.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.goldText,
                  size: 14,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _displayMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
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
