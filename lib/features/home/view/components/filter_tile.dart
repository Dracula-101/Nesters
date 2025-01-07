import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nesters/theme/theme.dart';

class FilterTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const FilterTile(
      {super.key,
      required this.title,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.onSurface.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Transform.scale(
              scale: 0.8,
              child: CupertinoCheckbox(
                activeColor: AppTheme.primary,
                value: isSelected,
                onChanged: (value) {},
              ),
            ),
            Flexible(
              child: Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
