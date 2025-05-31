import 'package:flutter/material.dart';

class ReusableFilter extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onSelected;

  const ReusableFilter({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = option == selectedOption;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                  children: [Text(option),],
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              selectedColor: Colors.white,
              backgroundColor: Colors.white,
              labelStyle: const TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }
}
