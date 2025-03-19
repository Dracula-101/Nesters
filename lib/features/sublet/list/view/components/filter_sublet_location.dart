import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class SubletLocationFilter extends StatefulWidget {
  final List<SubletModel> sublets;
  const SubletLocationFilter({super.key, required this.sublets});

  @override
  State<SubletLocationFilter> createState() => _SubletLocationFilterState();
}

class _SubletLocationFilterState extends State<SubletLocationFilter> {
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
    return FutureBuilder(
      future: Geolocator.getLastKnownPosition(),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return (snapshot.data != null)
              ? GoogleMapLocation(
                  lattitude: snapshot.data!.latitude,
                  longitude: snapshot.data!.longitude,
                  sublets: widget.sublets,
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
          return const Center(child: CircularProgressIndicator());
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
  final List<SubletModel> sublets;
  const GoogleMapLocation({
    super.key,
    required this.lattitude,
    required this.longitude,
    required this.sublets,
  });

  @override
  State<GoogleMapLocation> createState() => _GoogleMapLocationState();
}

class _GoogleMapLocationState extends State<GoogleMapLocation> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  CameraPosition? _kGooglePlex;
  final random = Random();
  final rootBundle = PlatformAssetBundle();

  @override
  void initState() {
    super.initState();
    _kGooglePlex = CameraPosition(
      target: LatLng(widget.lattitude, widget.longitude),
      zoom: 16,
    );
    _loadCustomIcon();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _loadCustomIcon() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/user/user_placeholder.png', 48);
    customIcon = BitmapDescriptor.fromBytes(markerIcon);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        buildingsEnabled: false,
        rotateGesturesEnabled: false,
        markers: <Marker>{
          Marker(
            markerId: const MarkerId('user_location'),
            position: LatLng(widget.lattitude, widget.longitude),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
          ...widget.sublets.map((sublet) {
            final randomLat = widget.lattitude +
                (random.nextDouble() - 0.5) * 0.1; // 0.1 is 10km in lat
            final randomLong = widget.longitude +
                (random.nextDouble() - 0.5) * 0.1; // 0.1 is 10km in long
            return Marker(
              markerId: MarkerId(sublet.id.toString()),
              position: LatLng(randomLat, randomLong),
              icon: customIcon,
              infoWindow: InfoWindow(
                title:
                    '${sublet.apartmentSize?.beds} Bed, ${sublet.apartmentSize?.baths} Bath',
                snippet: '\$${sublet.rent}',
              ),
            );
          }).toList()
        },
        initialCameraPosition: _kGooglePlex!,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
