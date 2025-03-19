import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nesters/theme/theme.dart';

class TopActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onClose;
  final VoidCallback? onTap;
  final bool isActive;
  final bool closeIcon;
  const TopActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onClose,
    this.onTap,
    required this.isActive,
    this.closeIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.greyShades.shade200,
          border: Border.all(
              color: isActive
                  ? AppTheme.primaryShades.shade400
                  : AppTheme.greyShades.shade400,
              width: isActive ? 2 : 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (closeIcon) ...[
              GestureDetector(
                onTap: onClose,
                child: Row(
                  children: [
                    Icon(
                      isActive ? Icons.close : icon,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ],
            Text(
              title,
              style: AppTheme.labelMedium,
            )
          ],
        ),
      ),
    );
  }
}
