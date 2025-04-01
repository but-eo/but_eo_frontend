import 'package:flutter/material.dart';
import 'package:project/widgets/image_slider_widgets.dart';

class Matchpage extends StatelessWidget {
  const Matchpage({super.key});

  @override
  Widget build(BuildContext context) {

    List<String> bannerUrlItems = [
      "assets/images/banner1.png",
      "assets/images/banner2.png",
    ];

    return Column(
      children: [
        ImageSliderWidgets(bannerUrlItems: bannerUrlItems),
      ],
    );
  }

  
}