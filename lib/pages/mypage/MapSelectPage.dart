import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSelectPage extends StatefulWidget {
  const MapSelectPage({super.key});

  @override
  State<MapSelectPage> createState() => _MapSelectPageState();
}

class _MapSelectPageState extends State<MapSelectPage> {
  LatLng? selectedLatLng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("지도에서 위치 선택")),
      body: GoogleMap(
        initialCameraPosition:
        const CameraPosition(target: LatLng(37.5665, 126.9780), zoom: 12),
        onTap: (latLng) {
          setState(() {
            selectedLatLng = latLng;
          });
        },
        markers: selectedLatLng != null
            ? {
          Marker(
            markerId: const MarkerId("selected"),
            position: selectedLatLng!,
          ),
        }
            : {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedLatLng != null) {
            Navigator.pop(context, selectedLatLng);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("위치를 선택해주세요")),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // 중앙 아래
    );
  }
}
