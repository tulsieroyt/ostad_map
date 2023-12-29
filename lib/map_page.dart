import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location location = Location();
  late GoogleMapController mapController;
  LocationData? currentLocation;
  List<LatLng> routePoints = [];
  Set<Polyline> polylines = {};
  bool isMapLoading = true;


  //to get current location
  void getCurrentLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    LocationData locationData = await location.getLocation();

    setState(() {
      currentLocation = locationData;
      routePoints.add(LatLng(locationData.latitude!, locationData.longitude!));
      isMapLoading = false;
    });

    updateLocation();
  }

  //to update location
  void updateLocation() async {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      LocationData newLocation = await location.getLocation();
      setState(() {
        currentLocation = newLocation;
        routePoints.add(LatLng(newLocation.latitude!, newLocation.longitude!));

        polylines.clear();
        polylines.add(Polyline(
          polylineId: const PolylineId('tracking_polyline'),
          points: routePoints,
          color: Colors.blue,
          width: 5,
        ));
      });
      animateCameraToLocation(newLocation);
    });
  }

  //to move the camera position
  void animateCameraToLocation(LocationData locationData) {
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(locationData.latitude!, locationData.longitude!),
        15,
      ),
    );
  }


  //to clear route history
  void clearRouteHistory() {
    setState(() {
      routePoints.clear();
      polylines.clear();
    });
  }



  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (!isMapLoading)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentLocation != null
                    ? LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!)
                    : const LatLng(0, 0),
                zoom: 15,
              ),
              onMapCreated: (controller) {
                mapController = controller;
              },
              markers: {
                if (currentLocation != null)
                  Marker(
                    markerId: const MarkerId('current_location'),
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    infoWindow: InfoWindow(
                      title: 'My current location',
                      snippet:
                      '${currentLocation!.latitude}, ${currentLocation!
                          .longitude}',
                    ),
                  ),
              },
              polylines: polylines,
            ),

          //when map is loading
          if (isMapLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          //button to clear route history
          Positioned(
            bottom: 16,
            left: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent.shade200,
              ),
              onPressed: () {
                clearRouteHistory();
              },
              child: const Text(
                'Clear Route History',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
