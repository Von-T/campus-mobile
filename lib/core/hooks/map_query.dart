import 'dart:core';
import 'dart:math';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/models/map.dart';
import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class MapQuery {
  /// The hook
  UseQueryResult<List<MapSearchModel>, dynamic>? mapHook;

  /// Default coordinates for Price Center
  double? _defaultLat = 32.87990969506536;
  double? _defaultLong = -117.2362059310055;

  /// Other data for map feature
  Coordinates? _coordinates;
  Map<MarkerId, Marker> _markers = Map<MarkerId, Marker>();
  TextEditingController _searchBarController = TextEditingController();
  GoogleMapController? _mapController;
  List<String> _searchHistory = [];

  /// NetworkHelper and endpoint to get data from the external server
  final NetworkHelper _networkHelper = NetworkHelper();
  final String baseEndpoint =
      "https://0dakeo6qfi.execute-api.us-west-2.amazonaws.com/qa/v2/map/search";

  /// Constructor that initializes the hook
  MapQuery() {
    mapHook = useFetchMapModel();
  }

  /// Create hook that retrieves and provides map location data in a 'MapSearchModel' schema
  /// @return UseQueryResult - flutter hook that updates asynchronously
  UseQueryResult<List<MapSearchModel>, dynamic> useFetchMapModel() {
    return useQuery(['map'], () async {
      /// fetch data
      String query = searchBarController.text;

      String? _response = await _networkHelper
          .fetchData(baseEndpoint + '?query=' + query + '&region=0');
      debugPrint("MapSearchModel QUERY HOOK: FETCHING DATA!");

      /// update the data in providers directory that is shared throughout the app
      populateDistances();
      reorderLocations();
      addMarker(0);

      if (!searchHistory.contains(query)) {
        // Check to see if this search is already in history...
        searchHistory.add(query); // ...If it is not, add it...
      } else {
        // ...otherwise...
        searchHistory
            .remove(query); // ...reorder search history to put it back on top
        searchHistory.add(query);
      }

      /// parse data
      final data = mapSearchModelFromJson(_response!);
      return data;
    });
  }

  void addMarker(int listIndex) {
    final Marker marker = Marker(
      markerId: MarkerId(mapHook!.data![listIndex].mkrMarkerid.toString()),
      position: LatLng(mapHook!.data![listIndex].mkrLat!,
          mapHook!.data![listIndex].mkrLong!),
      infoWindow: InfoWindow(
          title: mapHook!.data![listIndex].title,
          snippet: mapHook!.data![listIndex].description),
    );
    _markers.clear();
    _markers[marker.markerId] = marker;

    updateMapPosition();
  }

  void updateMapPosition() {
    if (_markers.isNotEmpty && _mapController != null) {
      _mapController!
          .animateCamera(
              CameraUpdate.newLatLng(_markers.values.toList()[0].position))
          .then((_) async {
        await Future.delayed(Duration(seconds: 1));
        try {
          _mapController!
              .showMarkerInfoWindow(_markers.values.toList()[0].markerId);
        } catch (e) {}
      });
    }
  }

  void reorderLocations() {
    mapHook!.data!.sort((MapSearchModel a, MapSearchModel b) {
      if (a.distance != null && b.distance != null) {
        return a.distance!.compareTo(b.distance!);
      }
      return 0;
    });
  }

  void removeFromSearchHistory(String item) {
    searchHistory.remove(item);
  }

  void populateDistances() {
    double? latitude =
        _coordinates!.lat != null ? _coordinates!.lat : _defaultLat;
    double? longitude =
        _coordinates!.lon != null ? _coordinates!.lon : _defaultLong;
    if (_coordinates != null) {
      for (MapSearchModel model in mapHook!.data!) {
        if (model.mkrLat != null && model.mkrLong != null) {
          var distance = calculateDistance(
              latitude!, longitude!, model.mkrLat!, model.mkrLong!);
          model.distance = distance as double?;
        }
      }
    }
  }

  num calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 0.621371;
  }

  ///SIMPLE GETTERS
  List<String> get searchHistory => _searchHistory;
  Map<MarkerId, Marker> get markers => _markers;
  Coordinates? get coordinates => _coordinates;
  TextEditingController get searchBarController => _searchBarController;
  GoogleMapController? get mapController => _mapController;

  ///Setters
  set coordinates(Coordinates? value) {
    _coordinates = value;
  }

  set searchBarController(TextEditingController value) {
    _searchBarController = value;
  }

  set mapController(GoogleMapController? value) {
    _mapController = value;
  }
}
