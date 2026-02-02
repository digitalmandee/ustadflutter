import 'dart:io';
import 'package:flutter/material.dart';

class ChildProfileModel {
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastname = TextEditingController();
  final TextEditingController grade = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController schoolName = TextEditingController();
  String? selectedCurriculum;
  final TextEditingController otherCurriculum = TextEditingController();

  String? selectedGender;
  File? selectedImage;

  void clear() {
    firstName.clear();
    lastname.clear();
    grade.clear();
    age.clear();
    schoolName.clear();
    selectedCurriculum = null;
    otherCurriculum.clear();
    selectedGender = null;
    selectedImage = null;
  }
}
