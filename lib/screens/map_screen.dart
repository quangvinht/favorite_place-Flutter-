import 'package:favorite_place/models/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 10.762622,
      longitude: 106.660172,
      address: 'Thành phố HCM',
    ),
    this.isSelecting = true,
  });

  final PlaceLocation location;
  final bool isSelecting;

  @override
  State<MapScreen> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends State<MapScreen> {
  PlaceLocation? _pickerdLocation;

  final mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSelecting ? "Pick your location" : 'Your location',
        ),
        actions: [
          if (widget.isSelecting)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(_pickerdLocation ?? widget.location);
              },
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            onTap: widget.isSelecting
                ? (tapPosition, point) async {
                    List<Placemark> placemarks = await placemarkFromCoordinates(
                        point.latitude, point.longitude,
                        localeIdentifier: 'en_US');
                    Placemark placemark = placemarks[0];
                    List<String> addressParts = [
                      if (placemark.street != null &&
                          placemark.street!.isNotEmpty)
                        placemark.street!,
                      if (placemark.subLocality != null &&
                          placemark.subLocality!.isNotEmpty)
                        placemark.subLocality!,
                      if (placemark.locality != null &&
                          placemark.locality!.isNotEmpty)
                        placemark.locality!,
                      if (placemark.subAdministrativeArea != null &&
                          placemark.subAdministrativeArea!.isNotEmpty)
                        placemark.subAdministrativeArea!,
                      if (placemark.administrativeArea != null &&
                          placemark.administrativeArea!.isNotEmpty)
                        placemark.administrativeArea!,
                      if (placemark.postalCode != null &&
                          placemark.postalCode!.isNotEmpty)
                        placemark.postalCode!,
                      if (placemark.country != null &&
                          placemark.country!.isNotEmpty)
                        placemark.country!,
                    ];
                    setState(() {
                      _pickerdLocation = PlaceLocation(
                        latitude: point.latitude,
                        longitude: point.longitude,
                        address: addressParts.join(", "),
                      );
                    });
                  }
                : null,
            initialCenter: _pickerdLocation != null
                ? LatLng(
                    _pickerdLocation!.latitude, _pickerdLocation!.longitude)
                : LatLng(widget.location.latitude, widget.location.longitude),
            initialZoom: 5.2,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              // Plenty of other options available!
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: _pickerdLocation != null
                      ? LatLng(
                          _pickerdLocation!.latitude,
                          _pickerdLocation!.longitude,
                        )
                      : LatLng(
                          widget.location.latitude,
                          widget.location.longitude,
                        ),
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
    );
  }
}
