import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';

class CountryPickerField extends StatefulWidget {
  final Function(String) onCountrySelected; // pass callback to parent

  const CountryPickerField({super.key, required this.onCountrySelected});

  @override
  State<CountryPickerField> createState() => _CountryPickerFieldState();
}

class _CountryPickerFieldState extends State<CountryPickerField> {
  Country _selected = Country.parse("PK"); // default to Pakistan

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.appText("Country",
            fontSize: 16,
            fontWeight: FontWeight.w500,
            textColor: AppTheme.lableText),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              onSelect: (Country country) {
                setState(() {
                  _selected = country;
                });
                widget.onCountrySelected(country.name); // update parent
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(_selected.flagEmoji),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_selected.name),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
