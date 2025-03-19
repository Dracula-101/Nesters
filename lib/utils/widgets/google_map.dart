import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/domain/models/user/location.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class MarkerInfo {
  final String id;
  final double lattiude;
  final double longitude;
  final String title;
  final String snippet;

  MarkerInfo({
    required this.id,
    required this.lattiude,
    required this.longitude,
    required this.title,
    required this.snippet,
  });
}

class GoogleMapLocation extends StatefulWidget {
  final List<MarkerInfo> markers;
  final Location? initialLocation;
  final double rangeRadius;
  final String tooltip;
  const GoogleMapLocation({
    super.key,
    required this.markers,
    required this.tooltip,
    this.initialLocation,
    this.rangeRadius = 5000,
  });

  @override
  State<GoogleMapLocation> createState() => _GoogleMapLocationState();
}

class _GoogleMapLocationState extends State<GoogleMapLocation> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final PlatformAssetBundle rootBundle = PlatformAssetBundle();
  final Set<Marker> markers = {};
  final LocalStorageRepository _localStorageRepository =
      GetIt.I<LocalStorageRepository>();

  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  LatLng? userLocation;
  CameraPosition? cameraPosition;
  bool isPositionMoved = false;

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
  }

  Future<Location> getLocation() async {
    double? latitude =
        _localStorageRepository.getDouble(LocalStorageKeys.locationLatitude);
    double? longitude =
        _localStorageRepository.getDouble(LocalStorageKeys.locationLongitude);
    if (latitude != null && longitude != null) {
      return Location(latitude: latitude, longitude: longitude);
    }
    final location = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10));
    _localStorageRepository.saveDouble(
        LocalStorageKeys.locationLatitude, location.latitude);
    _localStorageRepository.saveDouble(
        LocalStorageKeys.locationLongitude, location.longitude);
    return Location(latitude: location.latitude, longitude: location.longitude);
  }

  Future<void> _loadCurrentLocation() async {
    final position = widget.initialLocation ?? (await getLocation());
    userLocation = LatLng(position.latitude!, position.longitude!);
    final controller = await _controller.future;
    cameraPosition = CameraPosition(
        target: LatLng(position.latitude!, position.longitude!), zoom: 13);
    await controller
        .moveCamera(CameraUpdate.newCameraPosition(cameraPosition!));
    isPositionMoved = false;
    _addMarkers();
    setState(() {});
  }

  void _addMarkers() {
    markers.addAll(widget.markers.map((marker) {
      return Marker(
        markerId: MarkerId(marker.id),
        position: LatLng(marker.lattiude, marker.longitude),
        icon: customIcon,
        infoWindow: InfoWindow(
          title: marker.title,
          snippet: marker.snippet,
        ),
        zIndex: 0,
      );
    }));
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
        await getBytesFromAsset('assets/images/icons/home_map_marker.png', 110);
    customIcon = BitmapDescriptor.fromBytes(markerIcon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            boxShadow: [
              BoxShadow(
                color: AppTheme.onSurface.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(widget.tooltip)
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        child: CustomFlatButton(
          enabled: isPositionMoved,
          text: 'Apply',
          onPressed: () {
            Navigator.of(context).pop(
              (cameraPosition != null)
                  ? Location(
                      latitude: cameraPosition!.target.latitude,
                      longitude: cameraPosition!.target.longitude,
                    )
                  : null,
            );
          },
        ),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        buildingsEnabled: false,
        rotateGesturesEnabled: false,
        circles: {
          if (cameraPosition != null)
            Circle(
              circleId: const CircleId('user_location'),
              center: cameraPosition!.target,
              radius: widget.rangeRadius,
              fillColor: AppTheme.primary.withOpacity(0.2),
              strokeColor: AppTheme.primary,
              strokeWidth: 1,
            )
        },
        markers: {
          if (cameraPosition != null)
            Marker(
              markerId: const MarkerId('user_location'),
              position: cameraPosition!.target,
              icon: BitmapDescriptor.defaultMarker,
              zIndex: 1,
            ),
          ...markers,
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _loadCurrentLocation();
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 14,
        ),
        onCameraMove: (CameraPosition position) {
          cameraPosition = position;
          if (!isPositionMoved) {
            isPositionMoved = true;
          }
          setState(() {});
        },
      ),
    );
  }
}
