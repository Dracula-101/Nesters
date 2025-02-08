import 'package:flutter/material.dart';
import 'package:nesters/theme/theme.dart';

class AmentityWidget extends StatefulWidget {
  final bool value;
  final String title;
  final IconData icon;
  final Function(bool) onChanged;
  final double? iconsSize;
  const AmentityWidget(
      {super.key,
      required this.value,
      required this.title,
      required this.icon,
      required this.onChanged,
      this.iconsSize});

  @override
  State<AmentityWidget> createState() => _AmentityWidgetState();
}

class _AmentityWidgetState extends State<AmentityWidget> {
  bool currentValue = false;

  @override
  void initState() {
    super.initState();
    currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentValue = !currentValue;
          widget.onChanged(currentValue);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: currentValue
              ? AppTheme.primaryShades.shade100
              : AppTheme.greyShades.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                currentValue ? AppTheme.primary : AppTheme.greyShades.shade300,
            width: currentValue ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              color: currentValue
                  ? AppTheme.primary
                  : AppTheme.primaryShades.shade300,
              size: widget.iconsSize ?? 18,
            ),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: AppTheme.bodyMedium.copyWith(
                color: currentValue
                    ? AppTheme.primary
                    : AppTheme.primaryShades.shade300,
              ),
            ),
            const SizedBox(width: 8),
            if (currentValue)
              Icon(
                Icons.check,
                color: AppTheme.primary,
              )
            else
              Icon(
                Icons.close,
                color: AppTheme.primaryShades.shade300,
              ),
          ],
        ),
      ),
    );
  }
}
