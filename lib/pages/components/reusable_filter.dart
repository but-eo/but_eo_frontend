import 'package:flutter/material.dart';
import 'package:project/appStyle/app_colors.dart';

class ReusableFilter {
  static void show({
    required BuildContext context,
    required List<String> regions,
    required List<String> sports,
    required String selectedRegion,
    required String selectedSport,
    required void Function(String region, String sport) onApply,
  }) {
    String tempSelectedRegion = selectedRegion;
    String tempSelectedSport = selectedSport;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter modalSetState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("필터 설정", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                          ],
                        ),
                        const Divider(height: 24),
                        Text("지역 선택", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: regions.map((region) {
                            final isSelected = tempSelectedRegion == region;
                            return ChoiceChip(
                              label: Text(
                                region,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected
                                      ? AppColors.baseWhiteColor
                                      : AppColors.textPrimary.withAlpha(204),
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                modalSetState(() {
                                  tempSelectedRegion = region == tempSelectedRegion ? "전체" : region;
                                });
                              },
                              selectedColor: AppColors.brandBlue,
                              backgroundColor: AppColors.lightGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: isSelected ? AppColors.brandBlue : Colors.grey.shade300),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Text("종목 선택", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: sports.map((sport) {
                            final isSelected = tempSelectedSport == sport;
                            return ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    sport,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSelected
                                          ? AppColors.baseWhiteColor
                                          : AppColors.textPrimary.withAlpha(204),
                                    ),
                                  ),
                                  if (isSelected && sport != "전체")
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: Icon(Icons.close, size: 14, color: AppColors.baseWhiteColor),
                                    ),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                modalSetState(() {
                                  tempSelectedSport = sport == tempSelectedSport ? "전체" : sport;
                                });
                              },
                              selectedColor: AppColors.brandBlue,
                              backgroundColor: AppColors.lightGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: isSelected ? AppColors.brandBlue : Colors.grey.shade300),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              onApply(tempSelectedRegion, tempSelectedSport);
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            child: const Text("필터 적용", style: TextStyle(color: AppColors.baseWhiteColor)),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}
