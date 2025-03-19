import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/domain/models/user/location.dart';
import 'package:nesters/utils/widgets/google_map.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class ApartmentLocationFilter extends StatefulWidget {
  final List<ApartmentModel> apartments;
  final Location? location;
  const ApartmentLocationFilter(
      {super.key, required this.apartments, this.location});

  @override
  State<ApartmentLocationFilter> createState() =>
      _ApartmentLocationFilterState();
}

class _ApartmentLocationFilterState extends State<ApartmentLocationFilter> {
  final StreamController<LocationPermission> _permissionStream =
      StreamController<LocationPermission>.broadcast();

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  void _checkPermission() async {
    final permission = await Geolocator.checkPermission();
    _permissionStream.add(permission);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<LocationPermission>(
        stream: _permissionStream.stream,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data!) {
              case LocationPermission.whileInUse:
              case LocationPermission.always:
                return _buildLocationMap();
              case LocationPermission.denied:
                return _buildPermissionDenied(false);
              case LocationPermission.deniedForever:
                return _buildPermissionDenied(true);
              case LocationPermission.unableToDetermine:
                return ShowErrorWidget(
                  error: Exception('Permission Denied'),
                  message: 'Unable to determine location permission',
                  onRetry: () {
                    Navigator.of(context).pop();
                  },
                );
            }
          } else if (snapshot.hasError) {
            return ShowErrorWidget(
              error: snapshot.error as Exception,
              message: 'Failed to get location permission',
              onRetry: () {
                Navigator.of(context).pop();
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildPermissionDenied(bool isPermanentlyDenied) {
    return Center(
      child: ShowErrorWidget(
        error: Exception('Permission Denied'),
        message: isPermanentlyDenied
            ? 'You have denied the location permission permanently. Open settings to enable location service'
            : 'You have denied the location permission.',
        retryText: isPermanentlyDenied ? 'Open Settings' : 'Retry',
        onRetry: () async {
          if (isPermanentlyDenied) {
            await Geolocator.openLocationSettings();
          } else {
            final permission = await Geolocator.requestPermission();
            _permissionStream.add(permission);
          }
        },
      ),
    );
  }

  Widget _buildLocationMap() {
    return GoogleMapLocation(
      markers: widget.apartments.map((sublet) {
        return MarkerInfo(
          id: sublet.id.toString(),
          lattiude: sublet.location?.latitude ?? 0,
          longitude: sublet.location?.longitude ?? 0,
          title:
              '${sublet.apartmentSize?.beds} Bed, ${sublet.apartmentSize?.baths} Bath',
          snippet: '\$${sublet.rent}',
        );
      }).toList(),
      initialLocation: widget.location,
      tooltip: 'Move the marker to find the apartments within the radius.',
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
