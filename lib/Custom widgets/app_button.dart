import 'package:flutter/material.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';

class AppButton {
  static Widget appButton(
    String? text, {
    double? height,
    required BuildContext context,
    double? width,
    double? imgHeight,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    TextAlign? textAlign,
    Color? textColor,
    double? fontSize,
    String? image,
    GestureTapCallback? onTap,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? borderColor,
    TextBaseline? textBaseline,
    TextOverflow? overflow,
    var radius,
    double? letterSpacing,
    Color? imgColor,
    bool underLine = false,
    bool? border,
    bool? blurContainer,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: padding,
        width: width ?? ScreenSize(context).width,
        height: height ?? 44,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.primaryCOlor,
          borderRadius: BorderRadius.circular(radius ?? 8),
          border: border == false
              ? null
              : Border.all(color: borderColor ?? Colors.transparent, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            image == null
                ? SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: SizedBox(
                      height: imgHeight ?? 20,
                      width: imgHeight ?? 20,
                      child: Image(
                        image: AssetImage(image),
                        height: imgHeight ?? 16,
                        color: imgColor,
                      ),
                    ),
                  ),
            text == ""
                ? SizedBox.shrink()
                : AppText.appText(
                    text!,
                    fontSize: fontSize ?? 18,
                    textAlign: textAlign,
                    fontWeight: fontWeight ?? FontWeight.w500,
                    textColor: textColor ?? AppTheme.white,
                    overflow: overflow,
                    letterSpacing: letterSpacing,
                    textBaseline: textBaseline,
                    fontStyle: fontStyle,
                    underLine: underLine,
                  ),
          ],
        ),
      ),
    );
  }
}
