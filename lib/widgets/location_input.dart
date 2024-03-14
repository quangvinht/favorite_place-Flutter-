import 'package:favorite_place/models/place.dart';
import 'package:favorite_place/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_location/fl_location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onChooseLocation});

  final void Function(PlaceLocation loca) onChooseLocation;
  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickerdLocation;
  bool isGettingLocation = false;
  final mapController = MapController();
  // ignore: unused_element
  Future<bool> _checkAndRequestPermission({bool? background}) async {
    if (!await FlLocation.isLocationServicesEnabled) {
      // Location services are disabled.
      return false;
    }

    var locationPermission = await FlLocation.checkLocationPermission();
    if (locationPermission == LocationPermission.deniedForever) {
      // Cannot request runtime permission because location permission is denied forever.
      return false;
    } else if (locationPermission == LocationPermission.denied) {
      // Ask the user for location permission.
      locationPermission = await FlLocation.requestLocationPermission();
      if (locationPermission == LocationPermission.denied ||
          locationPermission == LocationPermission.deniedForever) return false;
    }

    // Location permission must always be allowed (LocationPermission.always)
    // to collect location data in the background.
    if (background == true &&
        locationPermission == LocationPermission.whileInUse) return false;

    // Location services has been enabled and permission have been granted.
    return true;
  }

  void getCurrentLocation() async {
    setState(() {
      isGettingLocation = true;
    });

    if (await _checkAndRequestPermission()) {
      const timeLimit = Duration(seconds: 10);
      await FlLocation.getLocation(timeLimit: timeLimit).then((location) async {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude, location.longitude,
            localeIdentifier: 'en_US');

        Placemark placemark = placemarks[0];

        List<String> addressParts = [
          if (placemark.street != null && placemark.street!.isNotEmpty)
            placemark.street!,
          if (placemark.subLocality != null &&
              placemark.subLocality!.isNotEmpty)
            placemark.subLocality!,
          if (placemark.locality != null && placemark.locality!.isNotEmpty)
            placemark.locality!,
          if (placemark.subAdministrativeArea != null &&
              placemark.subAdministrativeArea!.isNotEmpty)
            placemark.subAdministrativeArea!,
          if (placemark.administrativeArea != null &&
              placemark.administrativeArea!.isNotEmpty)
            placemark.administrativeArea!,
          if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty)
            placemark.postalCode!,
          if (placemark.country != null && placemark.country!.isNotEmpty)
            placemark.country!,
        ];

        setState(() {
          _pickerdLocation = PlaceLocation(
              latitude: location.latitude,
              longitude: location.longitude,
              address: addressParts.join(", "));
        });
        widget.onChooseLocation(_pickerdLocation!);
      }).onError((error, stackTrace) {
        print('error from location input: ${error.toString()}');
      });
    }

    setState(() {
      isGettingLocation = false;
    });
  }

  void selectedOnMap() async {
    final pickedLocation = await Navigator.of(context).push<PlaceLocation>(
      MaterialPageRoute(
        builder: (ctx) => const MapScreen(),
      ),
    );
    setState(() {
      _pickerdLocation = pickedLocation;
    });
    widget.onChooseLocation(_pickerdLocation!);

    if (pickedLocation == null) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
    );

    if (isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    if (_pickerdLocation != null) {
      previewContent = SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            onTap: (tapPosition, point) async {
              List<Placemark> placemarks = await placemarkFromCoordinates(
                  point.latitude, point.longitude,
                  localeIdentifier: 'en_US');
              Placemark placemark = placemarks[0];
              List<String> addressParts = [
                if (placemark.street != null && placemark.street!.isNotEmpty)
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
                if (placemark.country != null && placemark.country!.isNotEmpty)
                  placemark.country!,
              ];
              setState(() {
                _pickerdLocation = PlaceLocation(
                    latitude: point.latitude,
                    longitude: point.longitude,
                    address: addressParts.join(", "));
              });
            },
            // ignore: deprecated_member_use
            center:
                LatLng(_pickerdLocation!.latitude, _pickerdLocation!.longitude),
            // ignore: deprecated_member_use
            zoom: 5.2,
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
                  point: LatLng(
                    _pickerdLocation!.latitude,
                    _pickerdLocation!.longitude,
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
      );
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          height: 250,
          width: double.infinity,
          alignment: Alignment.center,
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Get current location'),
            ),
            TextButton.icon(
              onPressed: selectedOnMap,
              icon: const Icon(Icons.map),
              label: const Text('Selec on map'),
            )
          ],
        ),
      ],
    );
  }
}
