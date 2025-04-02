import 'package:flutter/cupertino.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ImageSliderWidgets extends StatelessWidget {
  const ImageSliderWidgets({Key? key, required this.bannerUrlItems})
      : super(key: key);

  final List<String> bannerUrlItems;

  @override
  Widget build(BuildContext context) {
    Size appSize = MediaQuery.of(context).size;
    return CarouselSlider.builder(
      itemCount: bannerUrlItems.length,
      itemBuilder: (context, itemIndex, realIndex) {
        return Stack(
          children: [
            Container(
              width: appSize.width,
              height: 200, // ✅ 높이 200 유지
              color: Colors.white, // 배경색 추가 (필요 시 조정)
              child: Image.asset(
                bannerUrlItems[itemIndex],
                fit: BoxFit.contain, // ✅ 이미지가 잘리지 않도록 수정
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Transform.translate(
                offset: Offset(-5, -25),
                child: Container(
                  constraints: BoxConstraints(maxHeight: 24, maxWidth: 40),
                  margin: const EdgeInsets.all(2.0),
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(248, 44, 41, 41),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "${itemIndex + 1}/${bannerUrlItems.length}",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      options: CarouselOptions(
        height: 200, // ✅ 높이 200 유지
        autoPlay: true,
        viewportFraction: 1,
      ),
    );
  }
}
