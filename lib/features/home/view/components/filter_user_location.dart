import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class UserLocationFilter extends StatefulWidget {
  const UserLocationFilter({super.key});

  @override
  State<UserLocationFilter> createState() => _UserLocationFilterState();
}

class _UserLocationFilterState extends State<UserLocationFilter> {
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
            return const Center(child: Text('Checking permission...'));
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
    return FutureBuilder(
      future: Geolocator.getLastKnownPosition(),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return (snapshot.data != null)
              ? GoogleMapLocation(
                  lattitude: snapshot.data!.latitude,
                  longitude: snapshot.data!.longitude,
                )
              : ShowErrorWidget(
                  error: Exception('Location not found'),
                  message: 'Failed to get location',
                  retryText: 'Close',
                  onRetry: () {
                    Navigator.of(context).pop();
                  },
                );
        } else if (snapshot.hasError) {
          return ShowErrorWidget(
            error: snapshot.error as Exception,
            message: 'Failed to get location',
            retryText: 'Close',
            onRetry: () {
              Navigator.of(context).pop();
            },
          );
        } else {
          return const Center(child: Text('Getting location...'));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class GoogleMapLocation extends StatefulWidget {
  final double lattitude;
  final double longitude;
  const GoogleMapLocation({
    super.key,
    required this.lattitude,
    required this.longitude,
  });

  @override
  State<GoogleMapLocation> createState() => _GoogleMapLocationState();
}

class _GoogleMapLocationState extends State<GoogleMapLocation> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  CameraPosition? _kGooglePlex;

  @override
  void initState() {
    super.initState();
    _kGooglePlex = CameraPosition(
      target: LatLng(widget.lattitude, widget.longitude),
      zoom: 14.4746,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        buildingsEnabled: false,
        compassEnabled: true,
        liteModeEnabled: true,
        markers: <Marker>{
          Marker(
            markerId: const MarkerId('user_location'),
            position: LatLng(widget.lattitude, widget.longitude),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        },
        initialCameraPosition: _kGooglePlex!,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
