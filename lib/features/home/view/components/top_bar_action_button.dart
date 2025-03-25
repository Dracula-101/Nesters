import 'package:flutter/material.dart';
import 'package:nesters/theme/theme.dart';

class TopActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onClose;
  final VoidCallback onTap;
  final bool isActive;
  final bool closeIcon;
  const TopActionButton({
    super.key,
    required this.title,
    required this.icon,
    this.onClose,
    required this.onTap,
    required this.isActive,
    this.closeIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
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
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                title,
                style: AppTheme.labelMedium,
              ),
            ),
            if (closeIcon) ...[
              if (isActive)
                Container(
                  height: 32,
                  width: 1,
                  color: AppTheme.greyShades.shade400,
                ),
              GestureDetector(
                onTap: () {
                  if (isActive) {
                    onClose?.call();
                  } else {
                    onTap();
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: SizedBox(
                  height: 32,
                  child: Row(
                    children: [
                      if (isActive) const SizedBox(width: 8),
                      Icon(
                        isActive ? Icons.close : icon,
                        size: 16,
                        color: AppTheme.greyShades.shade600,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
