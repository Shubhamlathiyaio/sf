import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/configs/app_typography.dart';
import '../../core/configs/gap.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final bool readOnly;
  final VoidCallback? onTap;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.keyboardType,
    this.textCapitalization,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: poppins.fs14.w500.textColor(
            Theme.of(context).colorScheme.onSurface,
          ),
        ),
        gap.h8,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _hasError
                  ? AppColors.error
                  : _isFocused
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: _isFocused || _hasError ? 2 : 1,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            validator: (value) {
              final error = widget.validator?.call(value);
              setState(() {
                _hasError = error != null;
                _errorText = error;
              });
              return error;
            },
            keyboardType: widget.keyboardType,
            textCapitalization:
                widget.textCapitalization ?? TextCapitalization.none,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            style: poppins.fs16.w400.textColor(
              Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: poppins.fs16.w400.textColor(
                Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Icon(
                        widget.prefixIcon,
                        size: 20.sp,
                        color: _hasError
                            ? AppColors.error
                            : _isFocused
                            ? AppColors.primary
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? GestureDetector(
                      onTap: widget.onSuffixTap,
                      child: Padding(
                        padding: EdgeInsets.all(12.r),
                        child: Icon(
                          widget.suffixIcon,
                          size: 20.sp,
                          color: _hasError
                              ? AppColors.error
                              : _isFocused
                              ? AppColors.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.prefixIcon != null ? 8.w : 16.w,
                vertical: 16.h,
              ),
              counterText: '', // Hide character counter
            ),
            onTapOutside: (event) {
              FocusScope.of(context).unfocus();
            },
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
            },
            onFieldSubmitted: (value) {
              FocusScope.of(context).unfocus();
            },
          ),
        ),
        if (_hasError && _errorText != null) ...[
          gap.h4,
          Row(
            children: [
              Icon(
                PhosphorIcons.warning(),
                size: 16.sp,
                color: AppColors.error,
              ),
              gap.w4,
              Expanded(
                child: Text(_errorText!, style: poppins.fs12.w400.error),
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {
        _isFocused = widget.controller.text.isNotEmpty;
      });
    }
  }
}
