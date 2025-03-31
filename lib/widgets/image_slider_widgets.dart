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
            Image.asset(
              bannerUrlItems[itemIndex],
              fit: BoxFit.cover,
              width: appSize.width,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Transform.translate(
                offset: Offset(-5, -25),
                child: Container(
                  height: null,
                  width: null,
                  constraints: BoxConstraints(maxHeight: 24, maxWidth: 40),
                  margin: const EdgeInsets.all(2.0), // 테두리 간격 추가
                  padding: const EdgeInsets.all(2.0), // 텍스트 주변 여백
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(248, 44, 41, 41), // 배경색
                    borderRadius: BorderRadius.circular(8.0), // 둥글게 만들기
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (itemIndex + 1).toString() +
                        "/" +
                        bannerUrlItems.length.toString(),
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
        height: 160,
        autoPlay: true,
        viewportFraction: 1, //화면에 1개의 이미지
      ),
    );
  }
}
