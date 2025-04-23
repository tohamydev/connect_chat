import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final String errorMessage;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;

  const CustomErrorWidget({
    Key? key,
    required this.errorMessage,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red.shade50,
        borderRadius: BorderRadius.circular(borderRadius ?? 10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        errorMessage,
        style: TextStyle(
          color: textColor ?? Colors.red,
          fontFamily: 'Cairo',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}