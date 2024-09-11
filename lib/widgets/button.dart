import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final String title;
  final Function? onPressed;
  final bool isLoading;
  final double? width;
  final Color? foregroundColor, backgroundColor;
  final double? fontSize;
  final double? height;
  final double? borderRadius;
  final IconData? icon;
  final Color? borderColor;
  final EdgeInsetsGeometry? margin;

  const PrimaryButton(
      {super.key,
      required this.title,
      this.width,
      this.onPressed,
      this.foregroundColor,
      this.backgroundColor,
      this.fontSize,
      this.borderColor,
      this.icon,
      this.height,
      this.margin,
      this.borderRadius = 10,
      required this.isLoading});

  @override
  _PrimaryButtonState createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
          widget.borderRadius == null ? 10 : widget.borderRadius!),
      child: Material(
        child: InkWell(
          onTap:
              widget.isLoading ? null : widget.onPressed as void Function()?,
          child: AnimatedContainer(
            curve: Curves.elasticInOut,
            margin: widget.margin,
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
                border: widget.borderColor != null
                    ? Border.all(color: widget.borderColor!)
                    : null,
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(
                    widget.borderRadius == null ? 10 : widget.borderRadius!)),
            height: widget.height ?? 50,
            width: widget.width ?? MediaQuery.of(context).size.width,
            child: Center(
              child: widget.isLoading!
                  ? Center(
                      child: Container(
                          child: CircularProgressIndicator(
                      color: widget.foregroundColor,
                    )))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title!,
                          style: TextStyle(
                              color: widget.foregroundColor,
                              fontSize: widget.fontSize ?? 22,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
