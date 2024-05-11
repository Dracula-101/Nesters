part of 'widgets.dart';

class CustomValuePicker extends StatefulWidget {
  final List<String> values;
  final String? firstValue, lastValue;
  final String? title;
  final double? height, width;
  const CustomValuePicker({
    super.key,
    required this.values,
    this.title,
    this.firstValue,
    this.lastValue,
    this.height,
    this.width,
  });

  @override
  State<CustomValuePicker> createState() => _CustomValuePickerState();
}

class _CustomValuePickerState extends State<CustomValuePicker> {
  String? _selectedItem;
  List<String>? allItems;
  @override
  Widget build(BuildContext context) {
    allItems = [
      if (widget.firstValue != null) widget.firstValue!,
      ...widget.values,
      if (widget.lastValue != null) widget.lastValue!,
    ];
    _selectedItem = allItems?[0];
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: Colors.transparent,
      child: Center(
        child: Container(
          height: widget.height ?? 300,
          width: widget.width ?? 250,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.shade200
                : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                child: Text(
                  widget.title ?? 'Select a value',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: StatefulBuilder(builder: (context, setState) {
                  return CupertinoPicker(
                    itemExtent: 30,
                    onSelectedItemChanged: (value) {
                      setState(() {
                        _selectedItem = allItems?[value];
                      });
                    },
                    children: [
                      for (var item in allItems ?? [])
                        Center(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                    ],
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, null);
                      },
                      child: Text(
                        'Reset',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, _selectedItem);
                      },
                      child: Text(
                        'Ok',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
