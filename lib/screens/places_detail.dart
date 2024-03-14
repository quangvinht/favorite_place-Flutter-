import 'package:favorite_place/models/place.dart';
import 'package:favorite_place/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ignore: must_be_immutable
class PlacesDetailScreen extends StatelessWidget {
  PlacesDetailScreen({super.key, required this.place});

  Place place;
  final mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
      ),
      body: Stack(
        children: [
          Image.file(
            place.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        onTap: (tapPosition, point) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => MapScreen(
                                location: place.location,
                                isSelecting: false,
                              ),
                            ),
                          );
                        },
                        // ignore: deprecated_member_use
                        interactiveFlags: 0,
                        // ignore: deprecated_member_use
                        center: LatLng(
                            place.location.latitude, place.location.longitude),
                        // ignore: deprecated_member_use
                        zoom: 8.2,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'dev.fleaflet.flutter_map.example',
                          // Plenty of other options available!
                        ),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: LatLng(place.location.latitude,
                                  place.location.longitude),
                              radius: 5000,
                              useRadiusInMeter: true,
                              color: Colors.red.withOpacity(0.3),
                              borderColor: Colors.red.withOpacity(0.7),
                              borderStrokeWidth: 2,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    place.location.address,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
