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
  final VoidCallback? onEditingComplete;
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

  const CustomDropdownField({
    super.key,
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
    this.enabled,
    this.onEditingComplete,
  });

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
            borderRadius: BorderRadius.circular(10),
            items: widget.items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e.toString(), style: AppTheme.bodyLarge),
                  ),
                )
                .toList(),
            value: widget.controller.text == '' ? null : widget.controller.text,
            onChanged: (value) {
              widget.controller.text = value.toString();
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
            onSaved: (value) {
              if (widget.onEditingComplete != null) {
                widget.onEditingComplete!();
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

class CustomSearchableDropDownField extends StatefulWidget {
  final TextEditingController controller;
  final Future<List<dynamic>> Function(String)? asyncItems;
  final bool Function(dynamic, String)? filterFn;
  final VoidCallback? onEditingComplete;
  final String? labelText;
  final String? hintText;
  final String? searchLabel;
  final Widget? prefixIcon;
  final Widget Function(BuildContext, dynamic, bool)? itemBuilder;
  final String? Function(dynamic)? validator;
  final String Function(dynamic)? itemAsString;

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
      this.itemAsString,
      this.onEditingComplete});

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
      padding: const EdgeInsets.only(left: 12),
      child: DropdownSearch(
        filterFn: (item, filter) {
          if (widget.filterFn != null) {
            return widget.filterFn!(item, filter);
          }
          return true;
        },
        decoratorProps: DropDownDecoratorProps(
          baseStyle: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: widget.labelText,
            prefixIcon: widget.prefixIcon,
            border: InputBorder.none,
          ),
        ),
        items: (filter, infiniteScrollProps) async {
          if (widget.asyncItems != null) {
            return await widget.asyncItems!(filter) as List<T>;
          }
          return <T>[];
        },
        popupProps: PopupProps.dialog(
          dialogProps: DialogProps(
            actions: [
              if (Platform.isIOS)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
            ],
          ),
          errorBuilder: (context, searchEntry, error) {
            return ShowErrorWidget(error: error);
          },
          emptyBuilder: (context, searchEntry) {
            return ShowInfoWidget(
              message: 'No items found',
              subtitle: 'No data related to \'$searchEntry\' found',
            );
          },
          containerBuilder: (context, child) {
            return Padding(
              padding: const EdgeInsets.only(
                left: 6.0,
                right: 6.0,
                top: 12.0,
              ),
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
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller.clear();
                },
              ),
            ),
          ),
          itemBuilder: (context, item, isSelected, isHighlighted) {
            if (widget.itemBuilder != null) {
              return widget.itemBuilder!(context, item, isSelected);
            }
            return ListTile(
              title: Text(item.toString(), style: AppTheme.bodyLarge),
            );
          },
          showSearchBox: true,
        ),
        onChanged: (value) {
          setState(() {
            widget.controller.text = widget.itemAsString != null
                ? widget.itemAsString!(value)
                : value.toString();
          });
          if (widget.onEditingComplete != null && value != null) {
            widget.onEditingComplete!();
          }
        },
        validator: (value) {
          if (widget.validator != null) {
            return widget.validator!(value);
          }
          return null;
        },
        itemAsString: (item) {
          if (widget.itemAsString != null) {
            return widget.itemAsString!(item);
          }
          return item.toString();
        },
        selectedItem:
            widget.controller.text == '' ? null : widget.controller.text,
      ),
    );
  }
}

class CustomBottomSheetDropdownField<T> extends StatefulWidget {
  final List<T> items;
  final TextEditingController controller;
  final void Function(dynamic)? onEditingComplete;
  final String? Function(dynamic) validator;
  final String? hintText;
  final String? bottomSheetTitle;
  final Widget? prefixIcon;
  final String? labelText;
  final bool? isMultiSelect;

  const CustomBottomSheetDropdownField({
    Key? key,
    required this.items,
    required this.controller,
    required this.validator,
    this.hintText,
    this.prefixIcon,
    this.labelText,
    this.bottomSheetTitle,
    this.isMultiSelect,
    this.onEditingComplete,
  }) : super(key: key);

  @override
  State<CustomBottomSheetDropdownField> createState() =>
      _CustomBottomSheetDropdownFieldState();
}

class _CustomBottomSheetDropdownFieldState<T>
    extends State<CustomBottomSheetDropdownField> {
  T? _selectedItem;

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isNotEmpty) {
      for (var item in widget.items) {
        if (widget.controller.text == item.toString()) {
          setState(() {
            _selectedItem = item;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.greyShades.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.only(left: 4),
      child: DropdownSearch<T>(
        decoratorProps: DropDownDecoratorProps(
          baseStyle: Theme.of(context).textTheme.labelLarge,
          decoration: InputDecoration(
            labelText: widget.labelText,
            prefixIcon: widget.prefixIcon,
            border: InputBorder.none,
          ),
        ),
        items: (filter, infiniteScrollProps) async => widget.items as List<T>,
        popupProps: PopupProps.modalBottomSheet(
          containerBuilder: (context, child) {
            return Padding(
              padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 12.0),
              child: child,
            );
          },
          errorBuilder: (context, searchEntry, error) {
            return ShowErrorWidget(error: error);
          },
          emptyBuilder: (context, searchEntry) {
            return ShowInfoWidget(
              message: 'No items found',
              subtitle: 'No data related to \'$searchEntry\' found',
            );
          },
          itemBuilder: (context, T? item, isSelected, isHighlighted) {
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
          widget.controller.text = value.toString();
          setState(() {
            _selectedItem = value;
          });
          if (widget.onEditingComplete != null && _selectedItem == null) {
            GetIt.I<AppLogger>().debug('Editing complete called');
            widget.onEditingComplete!(_selectedItem);
          }
        },
      ),
    );
  }
}

class CustomDynamicSearchableDropDropField extends StatefulWidget {
  final Stream<List<dynamic>> Function(String)? asyncSearchItems;
  final Widget Function(BuildContext, dynamic item)? itemBuilder;
  final Function(dynamic)? onItemClick;
  final Future<List<dynamic>>? asyncStaticItems;
  final String Function(dynamic)? itemAsString;
  final TextEditingController controller;
  final String? hintText;
  final String? searchText;
  final String? labelText;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String?)? validator;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final VoidCallback? onEditingComplete;
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
  final bool? autocorrect;
  final bool? enableSuggestions;
  final int? maxLines;
  final bool? alignLabelWithHint;
  final Widget Function(BuildContext)? emptyBuilder;

  const CustomDynamicSearchableDropDropField({
    super.key,
    this.asyncSearchItems,
    this.itemBuilder,
    this.onItemClick,
    this.asyncStaticItems,
    required this.controller,
    this.itemAsString,
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
    this.autocorrect,
    this.enableSuggestions,
    this.maxLines,
    this.alignLabelWithHint,
    this.searchText,
    this.emptyBuilder,
    this.onEditingComplete,
  });
  @override
  State<CustomDynamicSearchableDropDropField> createState() =>
      _CustomDynamicSearchableDropDropFieldState();
}

class _CustomDynamicSearchableDropDropFieldState
    extends State<CustomDynamicSearchableDropDropField> {
  dynamic _selectedItem;
  final Debouncer _debouncer = Debouncer(milliseconds: 1000);
  Stream<List<dynamic>>? _searchItems;
  List<dynamic>? _items = [];
  List<dynamic>? _filteredItems = [];
  final GlobalKey _rebuildKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppTheme.greyShades.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: () {
          _showDialog();
        },
        child: Padding(
          padding: widget.contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 6.0,
              ),
          child: TextFormField(
            enabled: false,
            controller: widget.controller,
            onChanged: (value) {
              setState(() {
                widget.controller.text = value;
              });
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
            onEditingComplete: () {
              if (widget.onEditingComplete != null) {
                widget.onEditingComplete!();
              }
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              labelText: widget.labelText,
              labelStyle: AppTheme.bodyLarge,
              hintStyle: AppTheme.labelLarge.copyWith(
                color: widget.hintTextColor ?? AppTheme.greyShades.shade700,
              ),
              alignLabelWithHint: widget.alignLabelWithHint ?? false,
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
        ),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) => PopScope(
        onPopInvoked: (value) {
          _rebuildKey.currentState?.setState(() {
            _searchItems = null;
            _filteredItems = null;
          });
        },
        child: Material(
            color: Colors.transparent,
            child: AlertDialog(
              clipBehavior: Clip.none,
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
              actionsPadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.zero,
              content: Column(
                children: [
                  _buildSearchBar(),
                  const Divider(),
                  Expanded(
                    child: _buildItemList(context),
                  ),
                  const Divider(),
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppTheme.greyShades.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: TextField(
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: widget.searchText ?? 'Search...',
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
        ),
        onChanged: _onSearchChanged,
        onSubmitted: _onSearchSubmitted,
      ),
    );
  }

  void _onSearchChanged(String value) {
    if (widget.asyncStaticItems != null) {
      _rebuildKey.currentState?.setState(() {
        _filteredItems = _items
            ?.where((element) => widget.itemAsString!(element)
                .toLowerCase()
                .contains(value.toLowerCase()))
            .toList();
      });
    } else if (widget.asyncSearchItems != null) {
      _debouncer.run(() {
        _rebuildKey.currentState?.setState(() {
          _searchItems = widget.asyncSearchItems!(value);
        });
      });
    }
  }

  void _onSearchSubmitted(String value) {
    setState(() {
      _searchItems = widget.asyncSearchItems?.call(value);
    });
  }

  Widget _buildItemList(BuildContext ctx) {
    return StatefulBuilder(
      key: _rebuildKey,
      builder: (_, setState) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: widget.asyncSearchItems == null
              ? FutureBuilder<List<dynamic>>(
                  future: widget.asyncStaticItems,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoading();
                    } else if (snapshot.hasError) {
                      return ShowErrorWidget(
                          error: snapshot.error as Exception);
                    } else if (snapshot.hasData) {
                      _items = snapshot.data;
                      _filteredItems = _filteredItems ?? _items;
                      return _buildListView(ctx, _filteredItems);
                    } else {
                      return _buildEmptyState();
                    }
                  },
                )
              : StreamBuilder<List<dynamic>>(
                  stream: _searchItems,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoading();
                    } else if (snapshot.hasError) {
                      return ShowErrorWidget(
                          error: snapshot.error as Exception);
                    } else if (snapshot.hasData) {
                      return _buildListView(ctx, snapshot.data);
                    } else {
                      return _buildEmptyState();
                    }
                  },
                ),
        );
      },
    );
  }

  Widget _buildListView(BuildContext ctx, List<dynamic>? items) {
    if (items == null || items.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 68),
      itemCount: items.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: widget.itemBuilder != null
              ? widget.itemBuilder!(context, items[index])
              : ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(widget.itemAsString!(items[index])),
                ),
          onTap: () => _onItemSelected(ctx, items[index]),
        );
      },
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyState() {
    return widget.emptyBuilder?.call(context) ??
        const Center(child: Text('No items found.'));
  }

  void _onItemSelected(BuildContext ctx, dynamic item) {
    _rebuildKey.currentState?.setState(() {
      _selectedItem = item;
      widget.controller.text = widget.itemAsString!(item);
    });
    widget.onItemClick?.call(_selectedItem);
    Navigator.of(ctx).pop(_selectedItem);
  }
}
