import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_link_model.dart';
import 'package:nesters/features/marketplace/form/cubit/marketplace_form_cubit.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class MarketplaceDetailsForm extends StatefulWidget {
  final TabController? controller;
  const MarketplaceDetailsForm({super.key, this.controller});

  @override
  State<MarketplaceDetailsForm> createState() => _MarketplaceDetailsFormState();
}

class _MarketplaceDetailsFormState extends State<MarketplaceDetailsForm>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _nameContoller = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _referenceLinkController =
      TextEditingController();
  MarketplaceCategoryModel? selectedCategory;
  MarketplaceLinkModel? selectedLink;
  DateTime? startDate, endDate;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _nameContoller.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _itemPriceController.dispose();
    _referenceLinkController.dispose();

    super.dispose();
  }

  bool validateAllFields() {
    selectedCategory = _categoryController.text.isNotEmpty
        ? MarketplaceCategoryModel(
            name: _categoryController.text,
            id: 1,
          )
        : null;
    if (_formKey.currentState!.validate()) {
      if (selectedCategory == null) {
        showErrorSnackBar('Please select a category');
        return false;
      }
      if (startDate == null) {
        showErrorSnackBar('Please select the start and end date');
        return false;
      }
      if (endDate != null) {
        if (endDate!.isBefore(startDate!)) {
          showErrorSnackBar('End date cannot be before start date');
          return false;
        }
      }
      return true;
    }
    return false;
  }

  void showErrorSnackBar(String message) {
    context.showErrorSnackBar(message);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<MarketplaceFormCubit, MarketplaceFormState>(
      listener: (context, state) {
        if (state.isValidating) {
          if (validateAllFields()) {
            context.read<MarketplaceFormCubit>().onPageChange(1);
            context.read<MarketplaceFormCubit>().showPageValid(1);
            context.read<MarketplaceFormCubit>().addFirstPageData(
                  name: _nameContoller.text,
                  address: _addressController.text,
                  description: _descriptionController.text,
                  itemPrice: double.parse(_itemPriceController.text),
                  startDate: startDate!,
                  endDate: endDate,
                  category: selectedCategory!,
                  link: selectedLink,
                );
            widget.controller!.animateTo(1);
          }
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNameField(),
              _buildSpacing(),
              _buildCategoryField(),
              _buildSpacing(),
              _buildDescription(),
              _buildSpacing(),
              _buildPriceField(),
              _buildSpacing(),
              _buildAddressField(),
              _buildSpacing(),
              _buildSubSectionTitle('Available Dates'),
              _buildSpacing(),
              _buildStartEndDate(),
              _buildSpacing(),
              _buildSubSectionTitle('Reference Links'),
              _buildSpacing(),
              _buildReferenceLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpacing({double height = 16}) {
    return SizedBox(height: height);
  }

  Widget _buildNameField() {
    return CustomTextField(
      controller: _nameContoller,
      labelText: 'Product Name',
      prefixIcon: Icon(
        FontAwesomeIcons.tag,
        color: AppTheme.greyShades.shade600,
        size: 22,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter the name of the product';
        }
        return null;
      },
      hintText: 'Ex. Study Table',
    );
  }

  Widget _buildCategoryField() {
    return CustomDynamicSearchableDropDropField(
      labelText: 'Category',
      hintText: 'Select the category',
      prefixIcon: Icon(
        FontAwesomeIcons.list,
        color: AppTheme.greyShades.shade600,
        size: 22,
      ),
      controller: _categoryController,
      asyncStaticItems: context.read<MarketplaceFormCubit>().getCategories(),
      itemAsString: (item) => item.name,
    );
  }

  Widget _buildDescription() {
    return CustomTextField(
      controller: _descriptionController,
      labelText: 'Description',
      prefixIcon: Icon(
        Icons.description_rounded,
        color: AppTheme.greyShades.shade600,
        size: 22,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter the description of the product';
        }
        return null;
      },
      hintText: 'Ex. A study table with 3 drawers',
    );
  }

  Widget _buildStartEndDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              ).then((value) {
                if (value != null) {
                  setState(() => startDate = value);
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.greyShades.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.calendarAlt,
                    color: AppTheme.greyShades.shade600,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('From Date'),
                        if (startDate != null)
                          Text(
                            startDate!.toShortUIDate(),
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.greyShades.shade600,
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              ).then((value) {
                if (value != null) {
                  setState(() => endDate = value);
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.greyShades.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.calendarAlt,
                    color: AppTheme.greyShades.shade600,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Till Date'),
                        if (endDate != null)
                          Text(
                            endDate!.toShortUIDate(),
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.greyShades.shade600,
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPriceField() {
    return CustomTextField(
      controller: _itemPriceController,
      labelText: 'Product Price',
      prefixIcon: Icon(
        FontAwesomeIcons.dollarSign,
        color: AppTheme.greyShades.shade600,
        size: 20,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter the product price';
        }
        return null;
      },
      keyboardType: TextInputType.number,
      hintText: 'Enter the product price',
    );
  }

  Widget _buildAddressField() {
    return CustomTextField(
      controller: _addressController,
      labelText: 'Address',
      prefixIcon: Icon(
        FontAwesomeIcons.locationDot,
        color: AppTheme.greyShades.shade600,
        size: 20,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter the address';
        }
        return null;
      },
      hintText: 'Enter the address',
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Divider(),
        Container(
          decoration: BoxDecoration(color: AppTheme.surface),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
          ),
        )
      ],
    );
  }

  Widget _buildReferenceLink() {
    return CustomTextField(
      labelText: 'Reference Link',
      prefixIcon: Icon(
        FontAwesomeIcons.link,
        color: AppTheme.greyShades.shade600,
        size: 20,
      ),
      hintText: 'Enter the reference link',
      controller: _referenceLinkController,
      onChanged: (value) {
        if (value.isNotEmpty) {
          String? referenceName;
          try {
            referenceName = Uri.parse(value).host.capitalize;
          } catch (e) {
            referenceName = null;
          }
          selectedLink = referenceName != null
              ? MarketplaceLinkModel(
                  link: value,
                  referenceName: referenceName,
                )
              : null;
          log('Selected Link: $referenceName');
        }
      },
      validator: (value) {
        if (value.isNotEmpty) {
          if (selectedLink == null) {
            return 'Please enter a valid link';
          }
        }
        return null;
      },
    );
  }
}
