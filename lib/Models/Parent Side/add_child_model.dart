import 'dart:io';
import 'package:flutter/material.dart';

class ChildProfileModel {
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastname = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController schoolName = TextEditingController();
  String? selectedCurriculum;
  String? selectedGrade;
  final TextEditingController otherCurriculum = TextEditingController();

  String? selectedGender;
  File? selectedImage;

  void clear() {
    firstName.clear();
    lastname.clear();
    age.clear();
    schoolName.clear();
    selectedCurriculum = null;
    selectedGrade = null;
    otherCurriculum.clear();
    selectedGender = null;
    selectedImage = null;
  }
}
