import 'package:flutter/material.dart';

class MainMenuActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color buttonColor;
  final Color borderColor;
  final Color textColor;
  final bool isPrimary;
  final bool isLocked;
  final VoidCallback onTap;

  const MainMenuActionButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonColor,
    required this.borderColor,
    required this.textColor,
    this.isPrimary = false,
    this.isLocked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: isPrimary ? 7.5 : (isLocked ? 5.5 : 6.0)),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isPrimary ? 1.8 : 1.2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: isPrimary ? 0.35 : (isLocked ? 0.08 : 0.18)),
                blurRadius: isPrimary ? 12 : 6,
                spreadRadius: isPrimary ? 1 : 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: textColor, size: isPrimary ? 19 : 17),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isLocked ? Colors.white70 : Colors.white,
                        fontSize: isPrimary ? 12.5 : 11.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textColor.withValues(alpha: isLocked ? 0.7 : 0.9),
                        fontSize: 9.0,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                isLocked ? Icons.lock_outline : Icons.arrow_forward_ios,
                color: textColor.withValues(alpha: 0.7),
                size: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
