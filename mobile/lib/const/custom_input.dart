
import 'package:app/const/custom_color.dart';
import 'package:app/const/custom_fontweight.dart';


import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String? text;
  final String? hintText;
  final IconData? prefixicon;
  final double? border;
  final Color? prefixIconColor;
  final double? height;
  final double? width;
  final double? fontsize;
  final VoidCallback? onTap;
  final BorderSide? borderSide;
  final String? Function(String?)? validator;
  final TextEditingController ? controller;
  final bool obscureText;
  final bool autofocus;
  final ValueChanged<String>?onChanged;

  const CustomInput({
    super.key,
    this.text,
    this.hintText,
    this.prefixIconColor,
    this.prefixicon,
    this.border,
    this.height,
    this.width,
    this.fontsize,
    this.borderSide,
    this.autofocus = false,
    this.controller,
    this.obscureText = false,
    this.onTap,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: TextFormField(
        controller:controller,
        
        autofocus: autofocus,
        onChanged: onChanged,
        validator: validator,
        obscureText:obscureText,
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: prefixicon != null ?Icon(prefixicon,color:prefixIconColor?? AppColor.grey,):null,
          hintText: hintText ?? "you@example.com",
          
          hintStyle:  TextStyle(fontSize: fontsize??13,color: AppColor.grey,fontWeight: AppFontWeight.bold),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          errorBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
         

          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
           
          ),
          enabledBorder: OutlineInputBorder(  
            borderSide: BorderSide(color: AppColor.bordercolor),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.blue),
            borderRadius: BorderRadius.circular(12),
          )
        ),
      ),
    );
  }
}
