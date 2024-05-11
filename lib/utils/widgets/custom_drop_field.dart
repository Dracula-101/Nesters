part of 'widgets.dart';

class CustomDropdownField<String> extends StatefulWidget {
  final List<String> items;
  // Text Controller property
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final String? validatorText;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final bool? autofocus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;
  final Color? fillColor;
  final Color? borderColor;
  final InputBorder? focusBorder;
  final InputBorder? enabledBorder;
  final InputBorder? disabledBorder;
  final InputBorder? errorBorder;
  final Color? cursorColor;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final Color? hintTextColor;
  final Color? textColor;
  final Color? backgroundColor;
  final String? errorText;
  final bool? isDense;
  final Function()? onTap;
  final bool? autocorrect;
  final bool? enableSuggestions;
  final int? maxLines;
  final bool? enabled;

  const CustomDropdownField(
      {super.key,
      required this.items,
      required this.controller,
      this.hintText,
      this.labelText,
      this.obscureText,
      this.keyboardType,
      this.textInputAction,
      this.validatorText,
      this.onFieldSubmitted,
      this.onChanged,
      this.autofillHints,
      this.focusNode,
      this.autofocus,
      this.prefixIcon,
      this.suffixIcon,
      this.contentPadding,
      this.margin,
      this.fillColor,
      this.borderColor,
      this.focusBorder,
      this.enabledBorder,
      this.disabledBorder,
      this.errorBorder,
      this.cursorColor,
      this.prefixIconColor,
      this.suffixIconColor,
      this.hintTextColor,
      this.textColor,
      this.backgroundColor,
      this.errorText,
      this.isDense,
      this.onTap,
      this.autocorrect,
      this.enableSuggestions,
      this.maxLines,
      this.enabled});

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField> {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppTheme.greyShades.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: Padding(
          padding: widget.contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 6.0,
              ),
          child: DropdownButtonFormField<String>(
            items: widget.items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e.toString(), style: AppTheme.bodyLarge),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return widget.validatorText;
              }
              return null;
            },
            focusNode: widget.focusNode,
            autofocus: widget.autofocus ?? false,
            decoration: InputDecoration(
              hintText: widget.hintText,
              labelText: widget.labelText,
              labelStyle: AppTheme.labelLarge.copyWith(
                color: widget.textColor ?? AppTheme.greyShades.shade700,
              ),
              hintStyle: AppTheme.labelLarge.copyWith(
                color: widget.hintTextColor ?? AppTheme.greyShades.shade700,
              ),
              errorText: widget.errorText,
              errorStyle: AppTheme.labelSmall.copyWith(
                  color: Theme.of(context).colorScheme.error, height: 1),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 40,
              ),
              contentPadding: widget.contentPadding ??
                  const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
              border: InputBorder.none,
              enabledBorder: widget.enabledBorder ?? InputBorder.none,
              focusedBorder: widget.focusBorder ?? InputBorder.none,
              disabledBorder: widget.disabledBorder ?? InputBorder.none,
              errorBorder: widget.errorBorder ?? InputBorder.none,
              isDense: widget.isDense ?? false,
            ),
            style: TextStyle(
              color:
                  widget.textColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomSearchableDropDownField<T> extends StatefulWidget {
  final TextEditingController controller;
  final Future<List<T>> Function(String)? asyncItems;
  final bool Function(T, String)? filterFn;
  final String? labelText;
  final String? hintText;
  final String? searchLabel;
  final Widget? prefixIcon;
  final Widget Function(BuildContext, T, bool)? itemBuilder;
  final String? Function(T?)? validator;
  final String Function(T)? itemAsString;

  const CustomSearchableDropDownField(
      {super.key,
      required this.controller,
      this.asyncItems,
      this.filterFn,
      this.labelText,
      this.hintText,
      this.searchLabel,
      this.prefixIcon,
      this.itemBuilder,
      this.validator,
      this.itemAsString});

  @override
  State<CustomSearchableDropDownField> createState() =>
      CustomSearchableDropDownFieldState();
}

class CustomSearchableDropDownFieldState<T>
    extends State<CustomSearchableDropDownField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.greyShades.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownSearch<T>(
        filterFn: (item, filter) {
          if (widget.filterFn != null) {
            return widget.filterFn!(item, filter);
          }
          return true;
        },
        dropdownDecoratorProps: DropDownDecoratorProps(
          baseStyle: Theme.of(context).textTheme.bodyLarge,
          dropdownSearchDecoration: InputDecoration(
            labelText: widget.labelText,
            prefixIcon: widget.prefixIcon,
            border: InputBorder.none,
          ),
        ),
        asyncItems: (filter) {
          if (widget.asyncItems != null) {
            return widget.asyncItems!(filter) as Future<List<T>>;
          }
          return Future.value([]);
        },
        popupProps: PopupProps.dialog(
          containerBuilder: (context, child) {
            return Padding(
              padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 12.0),
              child: child,
            );
          },
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              labelText: widget.searchLabel,
              prefixIcon: Icon(
                Icons.search,
                color: AppTheme.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          itemBuilder: (context, item, isSelected) {
            if (widget.itemBuilder != null) {
              return widget.itemBuilder!(context, item, isSelected);
            }
            return ListTile(
              title: Text(item.toString(), style: AppTheme.bodyLarge),
            );
          },
          showSearchBox: true,
        ),
        validator: (value) {
          if (widget.validator != null) {
            return widget.validator!(value);
          }
          return null;
        },
        itemAsString: widget.itemAsString,
      ),
    );
  }
}

class CustomBottomSheetDropdownField<T> extends StatefulWidget {
  final List<T> items;
  final TextEditingController controller;
  final Function(T?) validator;
  final String? hintText;
  final String? bottomSheetTitle;
  final Widget? prefixIcon;
  final String? labelText;

  const CustomBottomSheetDropdownField({
    Key? key,
    required this.items,
    required this.controller,
    required this.validator,
    this.hintText,
    this.prefixIcon,
    this.labelText,
    this.bottomSheetTitle,
  }) : super(key: key);

  @override
  State<CustomBottomSheetDropdownField> createState() =>
      _CustomBottomSheetDropdownFieldState();
}

class _CustomBottomSheetDropdownFieldState<T>
    extends State<CustomBottomSheetDropdownField> {
  T? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.greyShades.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.only(left: 4),
      child: DropdownSearch<T>(
        dropdownDecoratorProps: DropDownDecoratorProps(
          baseStyle: Theme.of(context).textTheme.labelLarge,
          dropdownSearchDecoration: InputDecoration(
            labelText: widget.labelText,
            prefixIcon: widget.prefixIcon,
            border: InputBorder.none,
          ),
        ),
        items: widget.items as List<T>,
        popupProps: PopupProps.modalBottomSheet(
          containerBuilder: (context, child) {
            return Padding(
              padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 12.0),
              child: child,
            );
          },
          itemBuilder: (context, T? item, isSelected) {
            return Row(
              children: [
                Checkbox(
                  value: _selectedItem == item,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedItem = item;
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                Text(item.toString(), style: AppTheme.bodyLarge),
              ],
            );
          },
          constraints: BoxConstraints(
            maxHeight: widget.items.length * 55,
          ),
          showSearchBox: false,
        ),
        validator: (value) {
          return widget.validator(value);
        },
        selectedItem: _selectedItem,
        onChanged: (value) {
          setState(() {
            _selectedItem = value;
          });
        },
      ),
    );
  }
}
