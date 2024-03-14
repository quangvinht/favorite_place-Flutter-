import 'dart:io';

import 'package:favorite_place/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatabase() async {
  // Get a location using getDatabasesPath
  final databasesPath = await sql.getDatabasesPath();
  final db =
      await sql.openDatabase(path.join(databasesPath, 'places_favorite.db'),
          // run first time:
          onCreate: (db, version) async {
    return await db.execute(
        'CREATE TABLE Places (id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL , lng REAL , address Text )');
  }, version: 1);

  return db;
}

class PlacesNotifier extends StateNotifier<List<Place>> {
  PlacesNotifier() : super(const []);

  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query('Places');
    final listPlaces = data
        .map(
          (row) => Place(
            id: row['id'] as String,
            title: row['title'] as String,
            image: File(row['image'] as String),
            location: PlaceLocation(
                latitude: row['lat'] as double,
                longitude: row['lng'] as double,
                address: row['address'] as String),
          ),
        )
        .toList();

    state = listPlaces;
  }

  void addPlace(Place place) async {
    // save image on devices:
    final Directory appDir = await syspath.getApplicationDocumentsDirectory();
    final fileName = path.basename(place.image.path);

    final copyImage = await place.image.copy('${appDir.path}/$fileName');

    final newPlace =
        Place(image: copyImage, title: place.title, location: place.location);

// Get a location using getDatabasesPath

    final db = await _getDatabase();

    await db.insert('Places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'lat': newPlace.location.latitude,
      'lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });
    state = [...state, newPlace];

    // Close the database
    await db.close();
  }
}

final placesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>(
  (ref) => PlacesNotifier(),
);
