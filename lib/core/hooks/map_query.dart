import 'dart:core';
import 'dart:math';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/models/map.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// NetworkHelper and endpoint to get data from the external server
final NetworkHelper _networkHelper = NetworkHelper();
final String baseEndpoint =
    "https://0dakeo6qfi.execute-api.us-west-2.amazonaws.com/qa/v2/map/search";

/// Create hook that retrieves and provides map location data in a 'MapSearchModel' schema
/// @return UseQueryResult - flutter hook that updates asynchronously
UseQueryResult<List<MapSearchModel>, dynamic> useFetchMapModel() {
  return useQuery(
    ['map'],
    () async {
      /// get local persistent data
      final mapsProvider = Provider.of<MapsDataProvider>(useContext());
      String query = mapsProvider.searchBarController.text;

      /// fetch data
      String? _response = await _networkHelper
          .fetchData(baseEndpoint + '?query=' + query + '&region=0');
      debugPrint("MapSearchModel QUERY HOOK: FETCHING DATA!");

      /// parse data
      final data = mapSearchModelFromJson(_response!);

      /// update the data in providers directory that is shared throughout the app
      // mapsProvider.markers.clear();
      // mapsProvider.populateDistances();
      // mapsProvider.reorderLocations();
      // mapsProvider.addMarker(0);
      // mapsProvider.updateSearchHistory(query);

      // mapsProvider.mapSearchModels = data;
      // mapsProvider.fetchLocations();

      return data;
    },
  );
}
