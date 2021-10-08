import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/core/providers/events.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/events/eventTile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventsAll extends StatelessWidget {
  const EventsAll({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider.of<EventsDataProvider>(context).isLoading!
        ? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary))
        : buildEventsList(
            Provider.of<EventsDataProvider>(context).eventsModels!, context);
  }

  Widget buildEventsList(List<EventModel> listOfEvents, BuildContext context) {
    final List<Widget> eventTiles = [];
    final screenSize = MediaQuery.of(context).size;
    double height = screenSize.height;
    double width = screenSize.width;

    for (int i = 0; i < listOfEvents.length; i++) {
      final EventModel item = listOfEvents[i];
      final tile = EventTile(data: item, height: height, width: width);
      eventTiles.add(tile);
    }

    if (listOfEvents != null && listOfEvents.length > 0) {
      return CustomScrollView(
        slivers: [
          SliverGrid.count(
            crossAxisCount: 2,
            children: eventTiles,
          )
        ],
      );
    } else {
      return ContainerView(
        child: Center(
          child: Text('No events found.'),
        ),
      );
    }
  }
}
