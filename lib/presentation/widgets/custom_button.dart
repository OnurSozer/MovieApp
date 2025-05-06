import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isFullWidth;
  final double height;
  final EdgeInsets? padding;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledBackgroundColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isFullWidth = true,
    this.height = 50,
    this.padding,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.disabledBackgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    
    // Determine button and text colors based on parameters and state
    final bgColor = isDisabled
        ? disabledBackgroundColor ?? AppColors.redDark
        : backgroundColor ?? (isPrimary
            ? AppColors.primaryButtonBackground
            : AppColors.secondaryButtonBackground);
            
    final fgColor = isDisabled
        ? AppColors.white.withOpacity(0.7)
        : textColor ?? (isPrimary
            ? AppColors.primaryButtonText
            : AppColors.secondaryButtonText);
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          disabledBackgroundColor: disabledBackgroundColor ?? AppColors.redDark,
          disabledForegroundColor: AppColors.white.withOpacity(0.7),
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: AppTextStyles.buttonLarge.copyWith(
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledBackgroundColor;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.disabledBackgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isPrimary: true,
      isFullWidth: isFullWidth,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      disabledBackgroundColor: disabledBackgroundColor,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledBackgroundColor;

  const SecondaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.disabledBackgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isPrimary: false,
      isFullWidth: isFullWidth,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      disabledBackgroundColor: disabledBackgroundColor,
    );
  }
} 