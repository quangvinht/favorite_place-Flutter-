import 'dart:io';

import 'package:favorite_place/models/place.dart';
import 'package:favorite_place/providers/places.dart';
import 'package:favorite_place/widgets/Image_input.dart';
import 'package:favorite_place/widgets/location_input.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceState();
}

class _AddPlaceState extends ConsumerState<AddPlaceScreen> {
  final formKey = GlobalKey<FormState>();
  String enterTitle = '';
  File? selectedFile;
  PlaceLocation? chosenLocation;

  void pickImage(File file) {
    selectedFile = file;
  }

  void chooseLocation(PlaceLocation loca) {
    chosenLocation = loca;
  }

  void handleSubmit() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (selectedFile == null) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            titleTextStyle: const TextStyle(color: Colors.red),
            backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            icon: const Icon(Icons.error),
            iconColor: Colors.red,
            title: const Text('Error'),
            content: const Text(
              'Please select a image',
              textAlign: TextAlign.center,
            ),
          ),
        );
        return;
      } else if (chosenLocation == null) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            titleTextStyle: const TextStyle(color: Colors.red),
            backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            icon: const Icon(Icons.error),
            iconColor: Colors.red,
            title: const Text('Error'),
            content: const Text(
              'Please choose location',
              textAlign: TextAlign.center,
            ),
          ),
        );
        return;
      } else {
      
        ref.read(placesProvider.notifier).addPlace(
              Place(
                  title: enterTitle,
                  image: selectedFile!,
                  location: chosenLocation!),
            );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add Place Success !!!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(label: Text('Title')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a place...';
                  }
                  return null;
                },
                maxLength: 20,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground),
                onSaved: (value) {
                  enterTitle = value!;
                },
              ),
              ImageInput(
                onPickImage: pickImage,
              ),
              //Remote Image upload

              const SizedBox(
                height: 16,
              ),
              LocationInput(
                onChooseLocation: chooseLocation,
              ),

              const SizedBox(
                height: 16,
              ),
              ElevatedButton.icon(
                onPressed: handleSubmit,
                label: const Text('Add place'),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
