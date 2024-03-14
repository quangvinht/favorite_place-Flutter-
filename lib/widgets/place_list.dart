import 'package:favorite_place/models/place.dart';
import 'package:favorite_place/screens/places_detail.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PlaceList extends StatelessWidget {
  PlaceList({super.key, required this.places});

  List<Place> places;

  @override
  Widget build(BuildContext context) {
    void handleToDetailPlaceScreen(Place place) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) {
            return PlacesDetailScreen(
              place: place,
            );
          },
        ),
      );
    }

    if (places.isEmpty) {
      return Center(
        child: Text(
          "No places added yet...",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Theme.of(context).colorScheme.onBackground),
        ),
      );
    }

    return ListView.builder(
      itemCount: places.length,
      itemBuilder: (ctx, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              radius: 26,
              backgroundImage: FileImage(places[index].image),
            ),
            onTap: () {
              handleToDetailPlaceScreen(
                places[index],
              );
            },
            title: Text(
              places[index].title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Theme.of(context).colorScheme.onBackground),
            ),
            subtitle: Text(
              places[index].location.address,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
          ),
        );
      },
    );
  }
}
