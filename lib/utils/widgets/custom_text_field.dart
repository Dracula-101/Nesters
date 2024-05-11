part of 'widgets.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? validator;
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
  const CustomTextField(
      {super.key,
      required this.controller,
      this.hintText,
      this.labelText,
      this.obscureText,
      this.keyboardType,
      this.textInputAction,
      this.validator,
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
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
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
            child: TextFormField(
              enabled: widget.enabled ?? true,
              controller: widget.controller,
              onChanged: (value) {
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
              },
              validator: (value) {
                if (widget.validator != null) {
                  return widget.validator!(value!);
                }
                return null;
              },
              onFieldSubmitted: (value) {
                if (widget.onFieldSubmitted != null) {
                  widget.onFieldSubmitted!(value);
                }
              },
              focusNode: widget.focusNode,
              autofillHints: widget.autofillHints,
              autofocus: widget.autofocus ?? false,
              obscureText: widget.obscureText ?? false,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              cursorColor: widget.cursorColor,
              autocorrect: widget.autocorrect ?? false,
              enableSuggestions: widget.enableSuggestions ?? false,
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
              maxLines: widget.maxLines ?? 1,
            ),
          )),
    );
  }
}
