import 'package:flutter/material.dart';
import 'package:nesters/theme/theme.dart';

class FilterTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const FilterTab(
      {super.key,
      required this.title,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.greyShades.shade300,
            ),
            left: BorderSide(
              color: isSelected ? AppTheme.primary : Colors.transparent,
              width: isSelected ? 6 : 0,
            ),
            right: BorderSide(
              color: AppTheme.greyShades.shade300,
            ),
          ),
          color: !isSelected ? AppTheme.greyShades.shade100 : AppTheme.surface,
        ),
        child: Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
