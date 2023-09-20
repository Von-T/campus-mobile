import 'package:campus_mobile_experimental/core/hooks/map_query.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

class MoreResultsList extends HookWidget {
  const MoreResultsList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapHooks = useFetchMapModel();
    return Align(
      alignment: Alignment.bottomCenter,
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Column(
              children: <Widget>[
                Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(
                    'More Results',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(
                  height: 0,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: mapHooks.data!.length,
                    itemBuilder: (BuildContext cntxt, int index) {
                      return ListTile(
                        title: Text(
                          mapHooks.data![index].title!,
                        ),
                        trailing: Text(
                          mapHooks.data![index].distance != null
                              ? mapHooks.data![index].distance!
                                      .toStringAsFixed(1) +
                                  ' mi'
                              : '--',
                          style: TextStyle(color: Colors.blue[600]),
                        ),
                        onTap: () {
                          Provider.of<MapsDataProvider>(cntxt, listen: false)
                              .addMarker(index);
                          Navigator.pop(cntxt);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          // primary: Theme.of(context).buttonColor,
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        child: Text(
          'Show More Results',
          style: TextStyle(color: Theme.of(context).textTheme.button!.color),
        ),
      ),
    );
  }
}
