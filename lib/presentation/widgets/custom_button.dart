import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/configs/app_typography.dart';
import '../../core/configs/gap.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool isOutlined;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.isLoading = false,
    this.isOutlined = false,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = isOutlined
        ? Colors.transparent
        : backgroundColor ?? AppColors.primary;

    final effectiveTextColor = isOutlined
        ? borderColor ?? AppColors.primary
        : textColor ?? Colors.white;

    final effectiveBorderColor = isOutlined
        ? borderColor ?? AppColors.primary
        : Colors.transparent;

    return Container(
      width: width ?? double.infinity,
      height: height ?? 56.h,
      decoration: BoxDecoration(
        color: onPressed == null
            ? AppColors.grey.withOpacity(0.3)
            : effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: onPressed == null ? Colors.transparent : effectiveBorderColor,
          width: isOutlined ? 2 : 0,
        ),
        boxShadow: !isOutlined && onPressed != null
            ? [
                BoxShadow(
                  color: (backgroundColor ?? AppColors.primary).withOpacity(
                    0.3,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: CircularProgressIndicator(
                      color: effectiveTextColor,
                      strokeWidth: 2,
                    ),
                  ),
                  gap.w12,
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20.sp,
                    color: onPressed == null
                        ? AppColors.grey
                        : effectiveTextColor,
                  ),
                  gap.w12,
                ],
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize ?? 16.sp,
                      fontWeight: fontWeight ?? FontWeight.w600,
                      color: onPressed == null
                          ? AppColors.grey
                          : effectiveTextColor,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Secondary button variant
class CustomSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;

  const CustomSecondaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: onPressed,
      text: text,
      icon: icon,
      isOutlined: true,
      borderColor: AppColors.primary,
    );
  }
}

// Danger button variant
class CustomDangerButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isOutlined;

  const CustomDangerButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: onPressed,
      text: text,
      icon: icon,
      backgroundColor: isOutlined ? Colors.transparent : AppColors.error,
      textColor: isOutlined ? AppColors.error : Colors.white,
      borderColor: AppColors.error,
      isOutlined: isOutlined,
    );
  }
}

// Small button variant
class CustomSmallButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isOutlined;

  const CustomSmallButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: onPressed,
      text: text,
      icon: icon,
      height: 40.h,
      fontSize: 14.sp,
      isOutlined: isOutlined,
    );
  }
}
