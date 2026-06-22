import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterustad/Helpers/app_theme.dart';

class CustomAppTextField extends StatefulWidget {
  final String? texthint;
  final TextEditingController? controller;
  final bool isPasswordField;
  final bool obscureText;
  final double? width;
  final double? height;
  final int? maxLines;
  final TextInputType? txtType;
  final bool? border;
  final bool? filledd;
  final Color? bgcolor;
  final Color? fillColor;
  final Color? textColor;
  final Color? cursorColor;
  final TextStyle? hintStyle;
  final Widget? prefixIcon;
  final Widget? suffix;
  final bool? readOnly;
  final TextDirection? textDirection;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  const CustomAppTextField({
    super.key,
    this.texthint,
    this.filledd,
    required this.controller,
    this.isPasswordField = false,
    this.obscureText = false,
    this.txtType,
    this.border,
    this.bgcolor,
    this.cursorColor,
    this.hintStyle,
    this.prefixIcon,
    this.onChanged,
    this.suffix,
    this.width,
    this.height,
    this.maxLines,
    this.readOnly,
    this.textColor,
    this.textDirection,
    this.onTap,
    this.fillColor,
    this.inputFormatters,
  });

  @override
  State<CustomAppTextField> createState() => _CustomAppTextFieldState();
}

class _CustomAppTextFieldState extends State<CustomAppTextField> {
  late bool _obscureText;
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    _obscureText = widget.isPasswordField;
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.controller != null) {
        widget.controller!.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.controller!.text.length),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 40,
      width: widget.width ?? MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: widget.border == false
            ? null
            : Border.all(color: const Color(0xffD4D8E2)),
        color: widget.bgcolor ?? const Color(0xffFFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        onTap: widget.onTap,
        textDirection: widget.textDirection ?? TextDirection.ltr,
        focusNode: _focusNode,
        readOnly: widget.readOnly ?? false,
        maxLines: widget.maxLines ?? 1,
        controller: widget.controller,
        obscureText: _obscureText,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: widget.txtType ?? TextInputType.name,
        inputFormatters: widget.inputFormatters,
        cursorColor: widget.cursorColor ?? AppTheme.appColor,
        onChanged: widget.onChanged,
        style: TextStyle(color: widget.textColor),
        decoration: InputDecoration(
          filled: widget.filledd,
          fillColor: widget.fillColor ?? AppTheme.white,
          isDense: true,
          border: InputBorder.none,
          contentPadding: widget.height != null
              ? const EdgeInsets.all(15)
              : const EdgeInsets.all(9),
          hintText: widget.texthint,
          hintStyle:
              widget.hintStyle ??
              TextStyle(
                color: AppTheme.hintColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: "InstrumentSans",
              ),
          prefixIcon: widget.prefixIcon,
          suffixIcon:
              widget.suffix ??
              (widget.isPasswordField
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppTheme.appColor,
                      ),
                    )
                  : null),
        ),
      ),
    );
  }
}

Widget parentHomeSearchField(
  context,
  controller, {
  ValueChanged<String>? onChanged,
  required String hintText,
}) {
  return Container(
    height: 44,
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xffD4D8E2)),
      color: const Color(0xffFFFFFF),
      borderRadius: BorderRadius.circular(8),
    ),
    child: TextFormField(
      maxLines: 1,
      controller: controller,
      keyboardType: TextInputType.name,
      cursorColor: AppTheme.appColor,
      onChanged: onChanged,
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(8),
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppTheme.hintColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
          child: Image.asset(
            "assets/images/search.png",
            color: Color(0xffA6ADBF),
          ),
        ),
      ),
    ),
  );
}
