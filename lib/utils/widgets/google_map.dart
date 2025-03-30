import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_sdk/google_places_sdk.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/user/location.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/bloc_state.dart';
import 'package:nesters/utils/debouncer.dart';
import 'package:nesters/utils/extensions/extensions.dart';
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
  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  final GooglePlaces _googlePlaces = GetIt.I<GooglePlaces>();
  final TextEditingController _searchController = TextEditingController();

  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  LatLng? userLocation;
  CameraPosition? cameraPosition;
  bool isPositionMoved = false;
  bool isSearchingLocation = false;
  BlocState mapSearchState = const BlocState(isLoading: false);
  List<AutocompletePrediction> places = [];

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _controller.future.then((controller) => controller.dispose());
  }

  Future<Location> getLocation() async {
    double? latitude =
        _localStorageRepository.getDouble(LocalStorageKeys.locationLatitude);
    double? longitude =
        _localStorageRepository.getDouble(LocalStorageKeys.locationLongitude);
    if (latitude != null && longitude != null) {
      return Location(latitude: latitude, longitude: longitude);
    }
    try {
      final position = await Geolocator.getCurrentPosition(
          timeLimit: const Duration(seconds: 7));
      _localStorageRepository.saveDouble(
          LocalStorageKeys.locationLatitude, position.latitude);
      _localStorageRepository.saveDouble(
          LocalStorageKeys.locationLongitude, position.longitude);
      return Location(
          latitude: position.latitude, longitude: position.longitude);
    } catch (e) {
      if (kDebugMode) {
        return Location(latitude: 40.641590, longitude: -74.010773);
      }
      rethrow;
    }
  }

  Future<void> _loadCurrentLocation() async {
    final position = widget.initialLocation ?? (await getLocation());
    userLocation = LatLng(position.latitude!, position.longitude!);
    final controller = await _controller.future;
    cameraPosition = CameraPosition(
        target: LatLng(position.latitude!, position.longitude!), zoom: 13);
    if (mounted) {
      await controller
          .moveCamera(CameraUpdate.newCameraPosition(cameraPosition!));
      isPositionMoved = false;
    }
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
    if (mounted) {
      setState(() {});
    }
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
    Uint8List? iconBytes;
    iconBytes = _localStorageRepository.getBytes(LocalStorageKeys.mapLocationIcon);
    if (iconBytes == null) {
      iconBytes = await getBytesFromAsset('assets/images/icons/home_map_marker.png', 110);
      await _localStorageRepository.saveBytes(LocalStorageKeys.mapLocationIcon, iconBytes);
    }
    customIcon = BitmapDescriptor.fromBytes(iconBytes);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _searchLocation(String query) async {
    try {
      final response = await _googlePlaces.getAutoCompletePredictions(query);
      places = response;
    } on AppException catch (e) {
      mapSearchState = BlocState(exception: e);
    } finally {
      mapSearchState = const BlocState(isLoading: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
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
              if (isSearchingLocation) ...[
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search location',
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            isSearchingLocation = false;
                          });
                        },
                      ),
                    ),
                    autofocus: true,
                    onChanged: (value) {
                      _debouncer.run(() async {
                        if (value.isNotEmpty) {
                          mapSearchState = const BlocState(isLoading: true);
                          if (mounted) setState(() {});
                          await _searchLocation(value);
                          if (mounted) setState(() {});
                        }
                      });
                    },
                  ),
                )
              ] else ...[
                Flexible(child: Text(widget.tooltip)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ]
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
      floatingActionButton: isSearchingLocation
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  isSearchingLocation = true;
                });
              },
              child: const Icon(Icons.search),
            ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            buildingsEnabled: false,
            zoomControlsEnabled: false,
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
              _addMarkers();
              if (mounted) setState(() {});
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
          if (isSearchingLocation)
            Container(
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
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  if (places.isEmpty) const SizedBox(height: 130),
                  if (mapSearchState.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (mapSearchState.exception != null)
                    ShowErrorWidget(
                      error: mapSearchState.exception!,
                      onRetry: () {},
                    )
                  else if (_searchController.text.isEmpty)
                    const ShowInfoWidget(
                      message: 'Search location',
                      subtitle: 'Enter location name to search',
                      icon: Icons.search,
                    )
                  else if (places.isEmpty)
                    const ShowNoInfoWidget(
                      title: 'No location found',
                      subtitle: 'Try searching with different keyword',
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: places.length,
                        itemBuilder: (context, index) {
                          final place = places[index];
                          return ListTile(
                            title: Text(place.fullName ?? ''),
                            subtitle: Text(place.secondaryText ?? ''),
                            onTap: () async {
                              try {
                                final placeDetails = await _googlePlaces
                                    .fetchPlaceDetails(place.placeId!);
                                final controller = await _controller.future;
                                cameraPosition = CameraPosition(
                                  target: LatLng(
                                    placeDetails.latLng!.lat!,
                                    placeDetails.latLng!.lng!,
                                  ),
                                  zoom: 13,
                                );
                                await controller.moveCamera(
                                    CameraUpdate.newCameraPosition(
                                        cameraPosition!));
                                isPositionMoved = false;
                              } catch (e) {
                                // ignore: use_build_context_synchronously
                                context.showErrorSnackBar(
                                  'Failed to load location',
                                  subtitle: e.toString(),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    isSearchingLocation = false;
                                  });
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
